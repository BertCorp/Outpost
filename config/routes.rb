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
    get "/to_do" => "users#to_do", as: :to_do
  end  
  
  resources :users, :companies, :reports, :test_suites, :reports, :test_cases, :pages, :test_results
  
  get 'new_marketing' => 'pages#new_marketing', as: 'new_marketing'
  get 'new_client_confirmation' => 'pages#new_client_confirmation', as: 'new_client_confirmation'
  
  root "pages#index"
  
end
