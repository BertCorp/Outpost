Outpost::Application.routes.draw do
  # Administrative Routes
  admin_constraint = lambda do |request|
    request.env['warden'].user && request.env['warden'].user.is_admin?
  end
  constraints admin_constraint do
    mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  end
  
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' },
    controllers: {
      registrations: 'users/registrations'
    }

  devise_scope :user do
    get "/logout" => "devise/sessions#destroy"
    get "/dashboard" => "users#dashboard", as: :dashboard
  end  
  
  resources :users
  resources :companies
  resources :test_suites # not sure if we need this...
  resources :test_cases, path: 'tests'
  resources :reports
  resources :pages

  get 'new_client_confirmation' => 'pages#new_client_confirmation', as: 'new_client_confirmation'
  
  root "pages#index"
  
end
