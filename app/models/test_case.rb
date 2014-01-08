class TestCase < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :test_suite
  has_many :results, class_name: 'TestResult'
  
  
  def status
    return results.last.status if results.any?
    return "Ready" if setup_completed_at.present?
    return "Pending" if pending_message.present?
    return "Being Setup" if setup_started_at.present?    
    'Awaiting Setup'
  end
  
end
