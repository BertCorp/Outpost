namespace :test do
  desc "Test::Test 1"
  task :test_1, [:id] => :environment do |t, args|
    args.with_defaults(:id => 'unknown')
    puts "Run test suite for client ##{args[:id]}"
    output = %x{ bundle exec rspec './tests/Test Client/test_suite.rb' }
    puts output.inspect
  end
end