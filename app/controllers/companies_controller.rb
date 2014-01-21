class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  # GET /company
  def edit
  end
  
  # PATCH/PUT /company
  # PATCH/PUT /company.json
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
        
        format.html { redirect_to [:admin, @company], notice: 'Company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
    def set_company
      @company = current_user.company
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit!
    end

end
