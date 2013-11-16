Outpost::Application.routes.draw do
  # Administrative Routes
  admin_constraint = lambda do |request|
    request.env['warden'].user && request.env['warden'].user.is_admin?
  end
  constraints admin_constraint do
    mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  end
  
  devise_for :users
  
  root "pages#index"
  
end
