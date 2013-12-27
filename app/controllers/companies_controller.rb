class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!

  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.where("name != 'Outpost'")
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
    @company.users << User.new if @company.users.count < 1
    @test_suite = TestSuite.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        params[:company][:users_attributes].each do |key, user|
          user[:company_id] = @company.id
          User.create(user)
          logger.info "Company users: #{@company.users.count}"
        end
        
        @test_suite = TestSuite.create(company_id: @company.id)
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render action: 'show', status: :created, location: @company }
      else
        format.html { render action: 'new' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        @company.users.each do |user|
          if params[:company][:users_attributes][user.id.to_s].present?
            # already exists! check to see if there are updates.
            logger.info "Compare/Update: "
            logger.info user.inspect
            logger.info params[:company][:users_attributes][user.id.to_s].inspect
            params[:company][:users_attributes].delete(user.id.to_s)
          else
            # no longer here. deleted?
            logger.info "Could Not found: #{user.inspect}"
          end
        end
        params[:company][:users_attributes].each do |key, user|
          user[:company_id] = @company.id
          User.create(user)
          logger.info "Company users: #{@company.users.count}"
        end
        
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit!
    end
end
