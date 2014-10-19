source 'https://rubygems.org'

# Core Ruby + Rails gems
ruby "2.1.2"
gem 'rails', '4.0.10'
gem 'sass-rails', '~> 4.0.1'
gem 'uglifier', '>= 1.3.0'
gem 'jbuilder', '~> 1.2'
#gem 'turbolinks'

# Front end gems
#gem 'jquery-rails'
#gem 'bootstrap-sass-rails', '~> 3.0'

# Use pg as the database for Active Record
gem 'pg'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end


# Devise
gem 'devise'
#gem 'devise_invitable'
#gem 'omniauth'
#gem 'omniauth-facebook'
#gem 'omniauth-twitter'
#gem 'omniauth-foursquare'
#gem 'omniauth-instagram'

# Pagination
gem 'will_paginate', '~> 3.0.4'
gem 'will_paginate-bootstrap'

# Data Management
gem 'rails_admin'

# Testing Setup
gem 'selenium-webdriver'
gem 'rspec'
gem 'rspec-rails'

group :development, :test do
  gem 'thin'
  gem 'guard-rspec', require: false
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'letter_opener'
end

# Heroku
group :staging, :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

# Addon Gems
gem 'newrelic_rpm'
gem 'sentry-raven'
gem 'intercom-rails'
gem 'delayed_job_active_record'
