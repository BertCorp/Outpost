class Admin::ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!
  layout 'admin'

  # GET /reports
  # GET /reports.json
  def index
    @reports = Report.all.paginate(page: params[:page], per_page: 10)
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
    end
    @report.monitored_by = current_user.id if current_user.is_admin?
  end
  
  # GET /reports/run
  def run
    params[:local] ||= 'false'
    @report = Report.new(company_id: params[:company], test_suite_id: params[:suite], test_environment_id: params[:environment])
    @report.initiated_at = Time.now
    @report.initiated_by = current_user.id
    @report.monitored_by = current_user.id if current_user.is_admin?
    @report.status = "Queued"
    
    respond_to do |format|
      if @report.save
        
        @report.test_suite.test_cases.order('id ASC').each do |test_case|
          @report.results.create({ status: 'Queued', report_id: @report, test_case_id: test_case.id, test_environment_id: @report.test_environment_id })
        end
        
        env = @report.test_environment.name.downcase
        env = 'staging' if env == 'mirror'
        ReportMailer.admin_triggered_report_email(@report).deliver
        @report.delay.run!(env, params[:local])
        
        format.html { redirect_to [:admin, @report], notice: 'Report has been queued and will start running soon.' }
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
    @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        
        @report.test_suite.test_cases.each do |test_case|
          @report.results.create({ status: 'Queued', report_id: @report, test_case_id: test_case.id})
        end
        
        format.html { redirect_to [:admin, @report], notice: 'Report was successfully created.' }
        format.json { render action: 'show', status: :created, location: @report }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  # GET /reports/latest/start
  # GET /reports/latest/start.json
  def start
    @reports = Report.where(company_id: params[:company], status: 'Queued').order('created_at DESC')
    respond_to do |format|
      if @reports.any?
        @report = @reports.first
        if @report.update({ started_at: Time.now, monitored_by: current_user.id, status: 'Running' })
          format.html { render text: "Running..." }
          format.json { head :no_content }
        else
          format.html { render text: @report.errors.inspect }
          format.json { render json: @report.errors, status: :unprocessable_entity }
        end
      else
        format.html { render text: "Report not found." }
        format.json { head :no_content }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to [:admin, @report], notice: 'Report was successfully updated.' }
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
      format.html { redirect_to admin_reports_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.fetch(:report, {}).permit(:company_id, :test_suite_id, :test_environment_id, :initiated_at, :initiated_by, :started_at, :completed_at, :monitored_by, :status, :summary, :created_at, :updated_at, 
      test_results_attributes: [:id, :report_id, :test_case_id, :status])
    end
end
