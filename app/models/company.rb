class Company < ActiveRecord::Base
  
  has_many :reports
  has_many :test_suites
  has_many :test_cases
  
  has_many :users
  accepts_nested_attributes_for :users
  #validates_associated :users
  
  def pending_tests
    test_cases.where("setup_started_at IS NULL")
  end
  
  def status
    # loop through each test suite
    test_suites.each do |suite|
      suite.reports.each do |report|
        # if there are any reports with a non-standard status, return it
        return report.status if report.status != 'Finished'
      end
      # return if any tests need to be setup
      return "#{pending_tests.count} tests need setup" if pending_tests.count > 0
    end
    "OK"
  end
    
end
