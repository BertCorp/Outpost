class Admin::TestResultsController < ApplicationController
  before_action :set_test_result, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!
  layout 'admin'

  # GET /test_results
  # GET /test_results.json
  def index
    @test_results = TestResult.all
  end

  # GET /test_results/1
  # GET /test_results/1.json
  def show
  end

  # GET /test_results/new
  def new
    @test_result = TestResult.new
  end

  # GET /test_results/1/edit
  def edit
  end

  # POST /test_results
  # POST /test_results.json
  def create
    @test_result = TestResult.new(test_result_params)

    respond_to do |format|
      if @test_result.save
        format.html { redirect_to [:admin, @test_result], notice: 'Test result was successfully created.' }
        format.json { render action: 'show', status: :created, location: @test_result }
      else
        format.html { render action: 'new' }
        format.json { render json: @test_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /test_results/1
  # PATCH/PUT /test_results/1.json
  def update
    respond_to do |format|
      if @test_result.update(test_result_params)
        format.html { redirect_to [:admin, @test_result.report], notice: 'Test result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @test_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /test_results/1
  # DELETE /test_results/1.json
  def destroy
    @test_result.destroy
    respond_to do |format|
      format.html { redirect_to admin_test_results_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_test_result
      @test_result = TestResult.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_result_params
      params.require(:test_result).permit(:report_id, :test_case_id, :started_at, :ended_at, :status, :summary, :execution_time, :created_at, :updated_at)
    end
end
