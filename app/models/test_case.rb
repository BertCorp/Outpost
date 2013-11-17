class TestCase < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :test_suite
  has_many :results, class_name: 'TestResult'
  
  
  def status
    return "ready" if setup_completed_at.present?
    return "pending" if pending_message.present?
    return "being setup" if setup_started_at.present?    
    'awaiting setup'
  end
  
end
