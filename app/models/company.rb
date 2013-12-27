class Company < ActiveRecord::Base
  
  has_many :reports
  has_one :test_suite
  has_many :test_cases, through: :test_suite
  
  has_many :users
  accepts_nested_attributes_for :users
  #validates_associated :users
    
end
