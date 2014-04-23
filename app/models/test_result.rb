class TestResult < ActiveRecord::Base
  
  belongs_to :report
  belongs_to :test_case
  belongs_to :test_environment

=begin
  Attributes: started_at, ended_at, status, summary, errors_raw
  Report Status Options
  Queued - In the queue to be run.
  Skipped - Test was skipped.
  Canceled - Test was canceled.
  Running - Test currently running.
  Failed - Test failed.
  Manual Review - Test is being reviewed by an associate.
  Pass - Test passed.
=end  

  def date
    return ended_at.strftime('%Y-%m-%d %T') if ended_at.present?
    return started_at.strftime('%Y-%m-%d %T') if started_at.present?
    created_at.strftime('%Y-%m-%d %T')
  end

  def statuses
    [
			["Queued - In the queue to be run.", "Queued"],
	  	["Skipped - Test was skipped.", "Skipped"],
	  	["Canceled - Test was canceled.", "Canceled"],
	  	["Running - Test currently running.", "Running"],
	  	["Failed - Test failed.", "Failed"],
	  	["Manual Review - Test is being reviewed by an associate.", "Manual Review"],
	  	["Passed - Test passed.", "Passed"]
		]
  end
  
end
