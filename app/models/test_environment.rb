class TestEnvironment < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :test_suite
  has_and_belongs_to_many :test_cases, join_table: 'test_cases_test_environments'
  has_many :reports
  has_many :test_results
  # Attributes: name, url
  
end
