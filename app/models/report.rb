require 'rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
Outpost::Application.load_tasks

class Report < ActiveRecord::Base
  
  belongs_to :company
  belongs_to :test_suite
  has_many :results, class_name: 'TestResult', dependent: :destroy
  has_many :test_cases, through: :results
  
  #belongs_to :initiator, class_name: 'User', foreign_key: 'initiated_by'
  belongs_to :monitorer, class_name: 'User', foreign_key: 'monitored_by'
  belongs_to :test_environment

  #Attributes: initiated_at, initiated_by (who clicked the “run test” button), started_at, completed_at, monitored_by (user_id -- Outpost employee), status, summary
  accepts_nested_attributes_for :results
  scope :user_reports, ->(user) { where(company_id: user.company_id) }  

  def date
    return completed_at.strftime('%Y-%m-%d %T') if completed_at.present?
    return started_at.strftime('%Y-%m-%d %T') if started_at.present?
    created_at.strftime('%Y-%m-%d %T')
  end
  
  def initiator
    return nil unless initiated_by.present?
    if initiated_by.to_s.is_numeric?
      User.find(initiated_by)
    elsif initiated_by[0] == 'u'
      User.find_by(authentication_token: initiated_by)
    elsif initiated_by[0] == 'c'
      Company.find_by(authentication_token: initiated_by)
    end
  end
  
  def run!(env = 'production', local = false)
    logger.info "Inside report: #{id}"
    Rake::Task['report:run'].reenable
    output = Rake::Task['report:run'].invoke(id, env, local)
    logger.info output
  end
  #handle_asynchronously :run!
  
end
