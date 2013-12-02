class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:edit, :update]
  before_action :authenticate_user!

  # GET /reports
  # GET /reports.json
  def index
    if current_user.is_admin?
      @reports = Report.all.paginate(page: params[:page], per_page: 10)
    else
      @reports = Report.user_reports(current_user).paginate(page: params[:page], per_page: 10)
    end
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
    @test_result = TestResult.new
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
          @report.results.create({ status: 'pending', report_id: @report, test_case_id: test_case.id})
        end
        
        ReportMailer.new_report_email(@report).deliver
        
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render action: 'show', status: :created, location: @report }
      else
        format.html { render action: 'new' }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
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
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.fetch(:report, {}).permit(:company_id, :test_suite_id, :initiated_at, :initiated_by, :started_at, :completed_at, :monitored_by, :status, :summary, :created_at, :updated_at, 
      test_results_attributes: [:id, :report_id, :test_case_id, :status])
    end
end
