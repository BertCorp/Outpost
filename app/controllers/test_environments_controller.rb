class TestEnvironmentsController < ApplicationController
  before_action :authenticate_user!

  # POST /environments
  # POST /environments.json
  def create
    @test_environment = TestEnvironment.new(test_environment_params)
    
    respond_to do |format|
      if @test_environment.save
        @test_case = TestCase.new
        @test_case.test_suite_id = current_user.company.test_suites.first.id
        @test_case.test_environment_ids = [@test_environment.id]
        
        #format.html { redirect_to dashboard_path, notice: 'Your new test environment was successfully added.' }
        format.html { render partial: 'test_cases/test_environments_container', locals: { test_case: @test_case } }
        format.json { render action: 'show', status: :created, location: @test_environment }
      else
        format.html { render action: 'new' }
        format.json { render json: @test_environment.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def test_environment_params
      params.require(:test_environment).permit(:company_id, :test_suite_id, :name, :url)
    end
end
