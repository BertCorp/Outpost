require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Test Cleanup" do

  before(:all) do
    $outpost.quit if $outpost
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit
  end
  
  it "test_99_cleanup" do
    begin
      $driver = start_driver({ name: 'Draft - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3

      start_logged_in

      count = $driver.find_elements(:css, ".document button.dropdown-toggle").count
      count.times do
        $driver.find_element(:css, ".document:nth-child(1) button.dropdown-toggle").click
        $driver.find_element(:css, 'li:nth-child(2) > a').click
        $driver.switch_to.alert.accept
        $driver.navigate.refresh
      end
      
      #pass(@test_id)
    rescue => e
      if e.inspect.include? 'id="IModalOverlay"'
        $driver.find_element(:css, '.ic_close_modal').click
        sleep(3)
        e.ignore
      end
      # If we get one of the following exceptions, its usually Browserstack's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to Browserstack exception: #{e.inspect}"
        sleep(10)
        retry
      end
      #fail(@test_id, e)
      raise
    end
  end
  
end
