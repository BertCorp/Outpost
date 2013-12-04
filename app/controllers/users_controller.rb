class UsersController < ApplicationController
  before_action :set_user, except: [:dashboard, :index, :to_do]
  before_action :authenticate_admin!, except: [:dashboard]
  before_action :authenticate_user!, only: [:dashboard]

  # GET /dashboard
  def dashboard
    @user = current_user
    @report = Report.new
    @reports = @user.company.reports.find(:all, :order => "id desc", :limit => 5)
  end
  
  def to_do
    @test_cases = TestCase.where(setup_completed_at: nil)
    @reports = Report.where(status: 'Queued')
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end
  
  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if params[:user][:password].blank?
      params[:user].delete :password
    end

    if @user.update(user_params)
      flash[:notice] = 'User was successfully updated.'
      redirect_to action: 'index' and return
    else
      render action: 'edit'
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    redirect_to users_url
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(
        :name, :email, :password, :company_id
      )
    end
end
