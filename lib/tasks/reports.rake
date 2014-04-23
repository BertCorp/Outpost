# $ bundle exec rake report:run[3,staging]
namespace :report do
  desc "Run Report Tests"
  task :run, [:report_id, :environment] => :environment do |t, args|
    args.with_defaults(:report_id => '0', :environment => 'production')
    puts "Run report: #{args}"
    report = Report.find(args.report_id)
    # Let's get things started...
    report.started_at = Time.now
    report.status = "Running"
    report.save!
    # Run the test suite
    output = %x{ENVIRONMENT=#{args.environment} bundle exec rspec "./tests/#{report.company.name}/test_suite.rb" }
    # Let's store results in report and update as completed.
    report.completed_at = Time.now
    report.errors_raw = output
    report.status = (output.include? 'FAILED') ? "Completed With Failures" : "Completed"
    report.save!
    # Mark any tests that weren't run as Skipped.
    report.test_suite.test_results.where(status: 'Queued').each do |test|
      test.status = 'Skipped'
      test.save!
    end
    
    puts output
  end
end