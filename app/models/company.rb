class Company < ActiveRecord::Base
  
  has_many :users
  has_many :reports
  has_one :test_suite
  has_many :test_cases, through: :test_suite
    
end
