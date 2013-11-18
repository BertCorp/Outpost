class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  private
  
    def authenticate_admin!
      authenticate_user!
      redirect_to dashboard_path, notice: "Sorry, but you don't have permission to do that." unless current_user.is_admin?
    end
    
end
