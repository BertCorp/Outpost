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
    environment = company.test_environments.where('name LIKE ?', args.environment)

    report = Report.new(company_id: company.id, test_suite_id: company.test_suites.first, test_environment_id: environment.id)
    report.initiated_at = Time.now
    report.status = "Running"
    report.save!
    
    ReportMailer.scheduled_report_triggered_email(report).deliver
    
    report.test_suite.test_cases.order('id ASC').each do |test_case|
      report.results.create({ status: 'Queued', report_id: report.id, test_case_id: test_case.id, test_environment_id: report.test_environment_id })
    end
    
    env = args.environment
    env = 'staging' if env == 'mirror'
    output = %x{ENVIRONMENT=#{env} LOCAL=false bundle exec rspec "./tests/#{company.name}/test_suite.rb" }
    
    report.completed_at = Time.now
    report.errors_raw = output
    report.status = ((output == '') || output.include?('FAILED')) ? "Under Review" : "Completed"
    report.save!
    # Mark any tests that weren't run as Skipped.
    report.results.where(status: 'Queued').each do |test|
      test.status = 'Skipped'
      test.save!
    end
    # mail results to admin, regardless
    ReportMailer.scheduled_report_completed_email(report, output).deliver
    
    puts output
  end
end