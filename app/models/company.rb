class Company < ActiveRecord::Base
  
  has_many :reports
  has_many :test_suites
  has_many :test_cases
  
  has_many :users
  accepts_nested_attributes_for :users
  #validates_associated :users
    
end
