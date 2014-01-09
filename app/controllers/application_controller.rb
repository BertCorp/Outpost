class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def after_sign_in_path_for(resource)
    dashboard_path
  end
  
  def after_sign_out_path_for(resource_or_scope)
    dashboard_path
  end
  
  def after_sign_up_path_for(resource)
    dashboard_path
  end
  
  private
  
    def authenticate_admin!
      authenticate_user!
      redirect_to dashboard_path, notice: "Sorry, but you don't have permission to do that." unless current_user.is_admin?
    end
        
end
