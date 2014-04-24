require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Test Cleanup" do

  before(:each) do
    $driver = start_driver({ name: 'Draft - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit
  end
  
  it "test_99_cleanup" do
    begin

      $driver.get(@base_url + 'documents')
      
      if $driver.current_url.include? "draft/users/sign_in"
        $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
        $driver.find_element(:id, "draft_user_password").send_keys "changeme"
        $driver.find_element(:name, "commit").click
      end
      
      count = $driver.find_elements(:css, ".document button.dropdown-toggle").count

      count.times do
        $driver.find_element(:css, ".document:nth-child(1) button.dropdown-toggle").click
        $driver.find_element(:css, 'li:nth-child(2) > a').click
        $driver.switch_to.alert.accept
        $driver.navigate.refresh
      end

      #pass(@test_id, Time.now - start_time)
    #rescue => e
      #fail(@test_id, Time.now - start_time, e)
      #raise
    end
  end
  
end
