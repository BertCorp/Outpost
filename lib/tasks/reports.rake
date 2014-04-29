# $ bundle exec rake report:run[3,staging,'true']
namespace :report do
  desc "Run Report Tests"
  task :run, [:report_id, :environment, :local] => :environment do |t, args|
    args.with_defaults(:report_id => '0', :environment => 'production', :local => 'false')
    puts "Run report: #{args}"
    report = Report.find(args.report_id)
    # Let's get things started...
    report.started_at = Time.now
    report.status = "Running"
    report.save!
    # Run the test suite
    output = %x{ENVIRONMENT=#{args.environment} LOCAL=#{args.local} bundle exec rspec "./tests/#{report.company.name}/test_suite.rb" }
    # Let's store results in report and update as completed.
    report.completed_at = Time.now
    report.errors_raw = output
    report.status = ((output == '') || output.include?('Failures:')) ? "Under Review" : "Completed"
    report.save!
    # Mark any tests that weren't run as Skipped.
    report.results.where(status: 'Queued').each do |test|
      test.status = 'Skipped'
      test.save!
    end
    # mail results to admin, regardless
    ReportMailer.admin_requested_report_status_email(report, output).deliver

    if report.status == 'Completed'
      ReportMailer.requested_report_successful_email(report).deliver
    end
    
    puts output
  end
end
