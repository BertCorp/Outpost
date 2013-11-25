class Report < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :test_suite
  has_many :results, class_name: 'TestResult'
  has_many :test_cases, through: :results
  
  belongs_to :initiator, class_name: 'User', foreign_key: 'initiated_by'
  belongs_to :monitorer, class_name: 'User', foreign_key: 'monitored_by'

  #Attributes: initiated_at, initiated_by (who clicked the “run test” button), started_at, completed_at, monitored_by (user_id -- Outpost employee), status, summary
  accepts_nested_attributes_for :results
end
