class TestResult < ActiveRecord::Base
  
  belongs_to :report
  belongs_to :test_case

=begin
  Attributes: started_at, ended_at, status, summary
  Report Status Options
  Queued - In the queue to be run.
  Skipped - Test was skipped.
  Canceled - Test was canceled.
  Running - Test currently running.
  Failed - Test failed.
  Pass - Test passed.
=end  
  
end
