#!/usr/bin/ruby

# Set suite variables:
$driver = nil
$is_test_suite = true
$wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
#require File.expand_path(File.dirname(__FILE__) + "/1 - test.rb")
Dir.glob(File.dirname(__FILE__) + "/*.rb").sort.each do |file| 
  require file unless ['test_suite.rb', 'client_variables.rb'].include? File.basename(file)
end
