class Company < ActiveRecord::Base
  
  has_many :reports, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  has_many :test_cases, dependent: :destroy
  
  has_many :users
  accepts_nested_attributes_for :users
  #validates_associated :users
  
  def chatroom
    return chatroom_url if chatroom_url.present?
    'http://www.hipchat.com/gpxnJo0u8' # should probably store in database to be updated easily from admin and not require code deploy.
  end
  
  def pending_tests
    test_cases.where("setup_started_at IS NULL")
  end
  
  def status
    # loop through each test suite
    test_suites.each do |suite|
      # return if any tests need to be setup
      return "Ready to Add Tests" if suite.test_cases.count < 1
      return "#{pending_tests.count} tests need setup" if pending_tests.count > 0
      return "Ready to Run Initial Report" if suite.reports.count < 1
      return suite.reports.order('created_at DESC').first.status if (suite.reports.count > 0) && (suite.reports.order('created_at DESC').first.status != 'Completed')
    end
    "Completed"
  end
    
end
