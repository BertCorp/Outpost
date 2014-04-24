class Admin::TestCasesController < ApplicationController
  before_action :set_test_case, only: [:show, :edit, :update, :destroy, :start, :finish, :setup_start, :setup_finish]
  before_action :authenticate_user!, except: [:start, :stop]
  layout 'admin'

  # GET /tests
  # GET /tests.json
  def index
    @test_cases = TestCase.all
  end

  # GET /tests/1
  # GET /tests/1.json
  def show
  end

  # GET /tests/new
  def new
    @test_case = TestCase.new
    @test_case.company_id = params[:company] if params[:company].present?
    @test_case.test_suite_id = params[:suite] if params[:suite].present?
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
        format.html { redirect_to [:admin, @test_case], notice: 'Test was successfully created.' }
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
        format.html { redirect_to [:admin, @test_case], notice: 'Test was successfully saved.' }
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
      format.html { redirect_to admin_test_cases_url }
      format.json { head :no_content }
    end
  end
  
  
  # GET /tests/1/start
  # GET /tests/1/start.json
  def start
    @test_case = TestCase.find(params[:id])
    @results = @test_case.results.where(status: 'Queued')
    respond_to do |format|
      if @results.any?
        @test_result = @results.last
        unless @test_result.started_at.present?
          if @test_result.update(started_at: Time.now, status: 'Running')
            format.html { render text: 'Running...' }
            format.json { head :no_content }
          else
            format.html { render text: @test_result.errors.inspect }
            format.json { render json: @test_result.errors, status: :unprocessable_entity }
          end
        else
          format.html { render text: 'Test not started.'}
          format.json { head :no_content }
        end
      else
        format.html { render text: 'Test not found.'}
        format.json { head :no_content }
      end   
    end
  end
  
  # GET /tests/1/stop
  # GET /tests/1/stop.json
  def stop
    @test_case = TestCase.find(params[:id])
    @results = @test_case.results.where(status: 'Running')
    respond_to do |format|
      if @results.any?
        @test_result = @results.last
        unless @test_result.ended_at.present?
          r = { 
            ended_at: Time.now, 
            status: params[:status], 
            execution_time: params[:execution] 
          }
          r[:errors_raw] = params[:message] if params[:message].present?
          
          if @test_result.update(r)
            format.html { render text: 'Stopped...' }
            format.json { head :no_content }
          else
            format.html { render text: @test_result.errors.inspect }
            format.json { render json: @test_result.errors, status: :unprocessable_entity }
          end
        else
          format.html { render text: 'Test already stopped.'}
          format.json { head :no_content }
        end
      else
        format.html { render text: 'Eligible test not found.'}
        format.json { head :no_content }
      end   
    end
  end
  
  
  # POST /tests/1/start
  # POST /tests/1/start.json
  def setup_start
    @test_case.setup_started_at = Time.now
    respond_to do |format|
      if @test_case.save
        format.html { redirect_to [:admin, @test_case], notice: 'Setup of test was successfully started.' }
        format.json { render action: 'show', status: :created, location: @test_case }
      else
        format.html { render action: 'new' }
        format.json { render json: @test_case.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /tests/1/finish
  # PUT /tests/1/finish.json
  def setup_finish
    @test_case.setup_completed_at = Time.now
    respond_to do |format|
      if @test_case.save
        format.html { redirect_to [:admin, @test_case], notice: 'Setup of test was successfully finished.' }
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
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def test_case_params
      params.require(:test_case).permit(:company_id, :test_suite_id, :title, :description, :setup_started_at, :setup_completed_at, :pending_message, :url, :created_at, :updated_at, :test_environment_ids => [])
    end
end
