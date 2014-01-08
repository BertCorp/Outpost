class UsersController < ApplicationController
  before_action :set_user, except: [:dashboard, :index]
  before_action :authenticate_admin!, except: [:dashboard]
  before_action :authenticate_user!, only: [:dashboard]

  # GET /dashboard
  def dashboard    
    @report = Report.new
    @reports = current_user.company.reports.find(:all, :order => "id desc", :limit => 5)
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
