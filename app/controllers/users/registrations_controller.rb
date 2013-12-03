class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_params

  def new   
    build_resource({})
    respond_with self.resource
  end

  def create
    @company = Company.find_or_create_by(name: params[:user][:company])
    @test_suite = TestSuite.create(company_id: @company.id)
    params[:user][:company_id] = @company.id
    
    super
  end
  
  def edit
    @user = User.find(current_user.id)
    super
  end

  # Override the devise update method for registrations
  def update
    @user = User.find(current_user.id)

    # See https://github.com/plataformatec/devise/wiki/How-To%3A-Allow-users-to-edit-their-account-without-providing-a-password
    successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(devise_parameter_sanitizer.for(:account_update))
    else
      params[:user].delete(:current_password)
      
      @user.update_without_password(devise_parameter_sanitizer.for(:account_update))
    end

    if successfully_updated
      sign_in @user, :bypass => true
      redirect_to dashboard_path, notice: 'User was successfully updated.'
    else
      render 'edit'
    end
  end

  private
  
    # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?(user, params)
      #user.email != params[:user][:email] ||
        params[:user][:password].present?
    end

    def configure_permitted_params
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(
          :name, :email, :company_id, :password, :password_confirmation
        )
      end
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(
          :name, :email, :company_id, :password, :password_confirmation, :current_password
        )
      end
    end
end
