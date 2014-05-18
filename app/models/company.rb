class Company < ActiveRecord::Base
  
  has_many :reports, dependent: :destroy
  has_many :test_suites, dependent: :destroy
  has_many :test_cases, dependent: :destroy
  
  has_many :users
  accepts_nested_attributes_for :users
  #validates_associated :users
  
  before_save :ensure_authentication_token
  
  def chatroom
    return chatroom_url if chatroom_url.present?
    'http://www.hipchat.com/gpxnJo0u8' # should probably store in database to be updated easily from admin and not require code deploy.
  end
  
  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
  
  def is_admin?
    false
  end
  
  def notify?
    test_suite.start_notifying_at.present?
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
  
  def test_suite
    test_suites.first
  end
  
  private

  def generate_authentication_token
    loop do
      token = "c_#{Devise.friendly_token}"
      break token unless Company.where(authentication_token: token).first
    end
  end
    
end
