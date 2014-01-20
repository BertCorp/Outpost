class TestCasesController < ApplicationController
  before_action :set_test_case, only: [:show]
  before_action :authenticate_user!

  # GET /test_cases/1
  # GET /test_cases/1.json
  def show
  end

  # GET /test_cases/new
  def new
    @test_case = TestCase.new
    @test_case.company_id = current_user.company_id
    @test_case.test_suite_id = current_user.company.test_suites.first.id if current_user.company.test_suites.count == 1
    
    logger.info current_user.company.test_suites.inspect
    logger.info @test_case.inspect
  end

  # POST /test_cases
  # POST /test_cases.json
  def create
    @test_case = TestCase.new(test_case_params)

    respond_to do |format|
      if @test_case.save
        TestMailer.admin_new_test_email(@test_case).deliver
        
        format.html { redirect_to @test_case, notice: 'Test was successfully added.' }
        format.json { render action: 'show', status: :created, location: @test_case }
      else
        format.html { render action: 'new' }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_case
      @test_case = TestCase.find(params[:id])
      redirect_to dashboard_path, notice: "Sorry, but you don't have permission to view that." unless @test_case.company_id == current_user.company_id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_case_params
      params.require(:test_case).permit(:company_id, :test_suite_id, :title, :description, :setup_started_at, :setup_completed_at, :pending_message, :created_at, :updated_at)
    end
end
