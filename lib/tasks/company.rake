# $ bundle exec rake company:run[3,staging]
namespace :company do
  desc "Test run Company Tests (no report!)"
  task :test, [:company_id, :environment] => :environment do |t, args|
    args.with_defaults(:company_id => '0', :environment => 'production')
    puts "Try to run tests for: #{args}"
    company = Company.find(args.company_id)
    output = %x{ENVIRONMENT=#{args.environment} bundle exec rspec "./tests/#{company.name}/test_suite.rb" }
    puts output
  end
  
  desc "Run Company Tests (report is generated!)"
  task :run, [:company_id, :environment] => :environment do |t, args|
    args.with_defaults(:company_id => '0', :environment => 'production')
    puts "Try to run tests for: #{args}"
    company = Company.find(args.company_id)
    environment = company.test_suites.first.test_environments.where('lower(name) LIKE ?', args.environment).first
    
    report = Report.new(company_id: company.id, test_suite_id: company.test_suites.first.id, test_environment_id: environment.id)
    report.initiated_at = Time.now
    report.started_at = Time.now
    report.status = "Running"
    report.save!
    
    ReportMailer.admin_scheduled_report_triggered_email(report).deliver
    
    report.test_suite.test_cases.order('id ASC').each do |test_case|
      report.results.create({ status: 'Queued', report_id: report.id, test_case_id: test_case.id, test_environment_id: report.test_environment_id })
    end
    
    env = args.environment
    env = 'staging' if env == 'mirror'
    output = %x{ENVIRONMENT=#{env} LOCAL=false bundle exec rspec "./tests/#{company.name}/test_suite.rb" }
    
    report.completed_at = Time.now
    report.errors_raw = output
    report.status = ((output == '') || output.include?('FAILED:')) ? "Under Review" : "Completed"
    report.save!
    # Mark any tests that weren't run as Skipped.
    report.results.where(status: 'Queued').each do |test|
      test.status = 'Skipped'
      test.save!
    end
    # mail results to admin, regardless
    ReportMailer.admin_scheduled_report_status_email(report, output).deliver
    
    if report.company.notify?
      if report.status == 'Completed'
        ReportMailer.requested_report_success_email(report).deliver
      else
        ReportMailer.requested_report_under_review_email(report).deliver
      end
    end
    
    puts output
  end
end