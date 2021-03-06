class ReportsController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:edit, :update]
  
  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.user_reports(current_user).order('created_at DESC').paginate(page: params[:page], per_page: 10)
    @report = Report.new(report_params)
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
    @results = @report.results
  end

  # GET /reports/new
  def new
    @report = Report.new
    if params[:company]
      @company = Company.find(params[:company])
      @report.company = @company
    end
    if params[:suite]
      @test_suite = TestSuite.find(params[:suite])
      @company = @test_suite.company
      @report.company = @company
      @report.test_suite = @test_suite
      @report.test_environment_id = @test_suite.test_environments.first.id if @test_case.test_suite.test_environments.count == 1
    end
    @report.monitored_by = current_user.id if current_user.is_admin?
  end
  
  # GET /reports/run
  def run
    params[:local] ||= false
    @report = Report.new(company_id: params[:company], test_suite_id: params[:suite], test_environment_id: params[:environment])
    @report.initiated_at = Time.now
    @report.initiated_by = current_user.id
    @report.status = "Queued"
    
    respond_to do |format|
      if @report.save
        
        @report.test_suite.test_cases.order('id ASC').each do |test_case|
          @report.results.create({ status: 'Queued', report_id: @report, test_case_id: test_case.id, test_environment_id: @report.test_environment_id })
        end
        
        env = @report.test_environment.name.downcase
        env = 'staging' if env == 'mirror'
        @report.delay.run!(env, params[:local])
        
        ReportMailer.admin_requested_report_triggered_email(@report).deliver
        ReportMailer.requested_report_triggered_email(@report).deliver

        format.html { redirect_to @report, notice: 'Your report has been queued and will start soon.' }
        format.json { render action: 'show', status: :created, location: @report }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end  
    end
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports
  # POST /reports.json
  def create
    if current_user.company.reports.any?
      if ["Queued", "Running"].include? current_user.company.reports.last.status
        redirect_to dashboard_path, notice: "Looks like you already have a report queued. We'll get to it asap, promise!"
        return
      end
    end
    
    @report = Report.new(report_params)    

    respond_to do |format|
      if @report.save
        
        @report.test_suite.test_cases.order('id ASC').each do |test_case|
          @report.results.create({ status: 'Queued', report_id: @report, test_case_id: test_case.id})
        end
        
        ReportMailer.admin_requested_report_triggered_email(@report).deliver
        #ReportMailer.requested_report_triggered_email(@report).deliver
        
        format.html { redirect_to dashboard_path }
        format.json { render action: 'show', status: :created, location: @report }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /report/:token
  # POST /report/:token
  def webhook
    ReportMailer.admin_webhook_email(request.fullpath, params, request.env).deliver
    # From: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # Insecure token authentication system. Simple requires providing the token
    # Should be extracted into an authenticate_with_token! method if used in more than one place.
    token = params[:token].presence
    logger.debug "Token: #{token.to_s}"
    if token[0] == 'u' # using a user's auth token
      user = User.find_by(authentication_token: token.to_s)
      # http://stackoverflow.com/questions/10253366/need-to-return-json-formatted-404-error-in-rails
      return render json: { error: "not-found" }.to_json, status: 404 if !user
      company = user.company
    elsif token[0] == 'c' # using a company's auth token
      company = Company.find_by(authentication_token: token.to_s)
      # http://stackoverflow.com/questions/10253366/need-to-return-json-formatted-404-error-in-rails
      return render json: { error: "not-found" }.to_json, status: 404 if !company
      # TODO: use optional params[:user] to swap token and identify user as one that triggered
    else # unknown auth token
      # http://stackoverflow.com/questions/10253366/need-to-return-json-formatted-404-error-in-rails
      return render json: { error: "not-found" }.to_json, status: 404
    end
    
    # Set delay to default (15 seconds) if not set
    params[:delay] ||= '15'
    
    # TODO: Flesh out to handle multiple test suites
    # TODO: Use optional params[:url] to identify testing suite
    # need to get test suite (default: first)
    test_suite = company.test_suites.first
    # TODO: Flesh out to handle multiple test environments properly
    # TODO: Use optional params[:environment] to identify testing environment
    # need to get test_environment (default: first || production)
    test_environment = test_suite.test_environments.first
    
    #render json: { company: company, test_suite: test_suite, test_environment: test_environment }
    @report = Report.new(company_id: company.id, test_suite_id: test_suite.id, test_environment_id: test_environment.id)
    @report.initiated_at = Time.now
    @report.initiated_by = token # store webhook as initiator
    @report.status = "Queued"
    
    if @report.save
      
      @report.test_suite.test_cases.order('id ASC').each do |test_case|
        @report.results.create({ status: 'Queued', report_id: @report, test_case_id: test_case.id, test_environment_id: @report.test_environment_id })
      end
      
      env = @report.test_environment.name.downcase
      env = 'staging' if env == 'mirror'
      @report.delay(run_at: params[:delay].to_i.seconds.from_now).run!(env, params[:local])

      # TODO: make sure proper mail is sent.
      ReportMailer.delay(run_at: params[:delay].to_i.seconds.from_now).admin_requested_report_triggered_email(@report)
      ReportMailer.delay(run_at: params[:delay].to_i.seconds.from_now).requested_report_triggered_email(@report)

      render json: @report.to_json( :only => [:id, :initiated_at, :initiated_by, :status, :created_at] ), status: :created, location: @report
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
      redirect_to dashboard_path, notice: "Sorry, but you don't have permission to view that." unless @report.company_id == current_user.company_id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.fetch(:report, {}).permit(:company_id, :test_suite_id, :test_environment_id, :initiated_at, :initiated_by, :started_at, :completed_at, :monitored_by, :status, :summary, :created_at, :updated_at, 
      test_results_attributes: [:id, :report_id, :test_case_id, :status])
    end
end
