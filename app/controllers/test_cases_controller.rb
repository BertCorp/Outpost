class TestCasesController < ApplicationController
  before_action :set_test_case, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /tests/1
  # GET /tests/1.json
  def show
  end

  # GET /tests/new
  def new
    @test_case = TestCase.new
    @test_case.company_id = current_user.company_id
    @test_case.test_suite_id = current_user.company.test_suites.first.id if current_user.company.test_suites.count == 1
    
    #logger.info current_user.company.test_suites.inspect
    #logger.info @test_case.inspect
  end

  # GET /tests/1/edit
  def edit
  end

  # POST /tests
  # POST /tests.json
  def create
    @test_case = TestCase.new(test_case_params)

    respond_to do |format|
      if @test_case.save
        TestMailer.admin_new_test_email(@test_case).deliver
        
        format.html { redirect_to @test_case, notice: 'Your test was successfully added.' }
        format.json { render action: 'show', status: :created, location: @test_case }
      else
        format.html { render action: 'new' }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PATCH/PUT /tests/1
  # PATCH/PUT /tests/1.json
  def update
    respond_to do |format|
      if @test_case.update(test_case_params)
        TestMailer.admin_test_updated_email(@test_case).deliver
        
        format.html { redirect_to @test_case, notice: 'Your test was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tests/1
  # DELETE /tests/1.json
  def destroy
    @test_case.destroy
    respond_to do |format|
      format.html { redirect_to test_cases_url }
      format.json { head :no_content }
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
      params.require(:test_case).permit(:company_id, :test_suite_id, :title, :description, :setup_started_at, :setup_completed_at, :pending_message, :url, :created_at, :updated_at, :test_environment_ids => [])
    end
end
