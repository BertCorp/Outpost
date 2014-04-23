#!/usr/bin/ruby

# Set suite variables:
$driver = nil
$is_test_suite = true
#require File.expand_path(File.dirname(__FILE__) + "/1 - test.rb")
Dir[File.expand_path(File.dirname(__FILE__) + "/*.rb")].each do |file| 
  require file unless ['test_suite.rb', 'client_variables.rb'].include? File.basename(file)
end
