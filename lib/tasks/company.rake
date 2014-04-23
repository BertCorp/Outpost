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
  task :test, [:company_id, :environment] => :environment do |t, args|
    args.with_defaults(:company_id => '0', :environment => 'production')
    puts "Try to run tests for: #{args}"
    company = Company.find(args.company_id)
    output = %x{ENVIRONMENT=#{args.environment} bundle exec rspec "./tests/#{company.name}/test_suite.rb" }
    puts output
  end
end