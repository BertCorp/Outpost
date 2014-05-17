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
      redirect_to dashboard_path, notice: "Sorry, but you don't have permission to do that." unless current_user && current_user.is_admin?
    end
    
    # From: https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # Insecure token authentication system. Simple requires providing the token
    def authenticate_from_token!
      token = params[:token].presence
      if token
        logger.debug "Token: #{token.to_s}"
        if token[0] == 'u'
          user = User.find_by(authentication_token: token.to_s)

          if user
            # The user is not actually stored in the session and a token is needed for every request. 
            # If you want the token to work as a sign in token, you can simply remove store: false.
            sign_in user, store: false
          end
        elsif token[0] == 'c'
          current_company = Company.find_by(authentication_token: token.to_s)
        end
      end
    end
        
end
