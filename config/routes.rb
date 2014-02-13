Outpost::Application.routes.draw do
  # Administrative Routes
  admin_constraint = lambda do |request|
    request.env['warden'].user && request.env['warden'].user.is_admin?
  end
  constraints admin_constraint do
    mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'
  end
  
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'signup' },
    controllers: {
      registrations: 'users/registrations'
    }

  devise_scope :user do
    get "/logout" => "devise/sessions#destroy"
    get "/dashboard" => "users#dashboard", as: :dashboard
    get "/account" => "users/registrations#edit", as: :account
    get "/company" => "companies#edit", as: :company
    patch "/company" => "companies#update"
    put "/company" => "companies#update"
  end
  
  namespace 'admin' do
    root 'admin#index'
    resources :users
    resources :companies
    resources :test_suites # not sure if we need this...

    resources :test_cases, path: 'tests' do
      get "start" => "test_cases#start", on: :member
      get "stop" => "test_cases#stop", on: :member
      post "start" => "test_cases#setup_start", as: :start_setup, on: :member
      put "finish" => "test_cases#setup_finish", as: :finish_setup, on: :member
    end

    resources :reports do
      get "latest/start" => "reports#start", on: :collection
    end
    
    resources :test_results, path: 'results'
  end
  
  resources :users
  
  resources :reports
  resources :test_cases, path: 'tests'
  resources :test_results, path: 'results'
  resources :test_environments, path: 'environments'
  resources :pages

  get 'thankyou' => 'pages#new_client_confirmation', as: 'new_client_confirmation'
  
  root "pages#index"
  
end
