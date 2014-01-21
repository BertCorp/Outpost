class TestCase < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :test_suite
  has_and_belongs_to_many :test_environments, join_table: 'test_cases_test_environments'
  has_many :results, class_name: 'TestResult', dependent: :destroy
  
  
  def status
    return results.last.status if results.any?
    return "Ready" if setup_completed_at.present?
    return "Pending" if pending_message.present?
    return "Being Setup" if setup_started_at.present?    
    'Awaiting Setup'
  end
  
end
