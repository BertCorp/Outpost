require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Test A User Can Start A Test" do

  before(:each) do
    @test_id = "34"
    start(@test_id)
    $driver = start_driver({ name: 'Outpost - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_3_test_a_user_can_start_a_test" do
    begin
      start_time = Time.now
      $driver.get(@base_url + "dashboard")
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:css, "p").text).should == "Please note: We are currently running your tests. We will send you a report with the results as soon as they are done."
      ($driver.find_element(:xpath, "//div[3]/table/tbody/tr[2]/td").text).should == "Queued"
      $driver.find_element(:link, "View").click
      verify { $driver.find_element(:css, "h2").text.should =~ /^exact:Report generated for [\s\S]*Test Company[\s\S]*$/
      ($driver.find_element(:css, "p").text).should == "Current Status: Queued"
      ($driver.find_element(:css, "td").text).should == "Provider can login using username/password combination of demo/demo"
      ($driver.find_element(:xpath, "//tr[3]/td").text).should == "Provider can add new appointment"
      ($driver.find_element(:xpath, "//tr[4]/td").text).should == "Provider can search for a specific appointment by customer name or phone number"
      ($driver.find_element(:xpath, "//tr[5]/td").text).should == "Provider can edit appointment"
      ($driver.find_element(:xpath, "//tr[6]/td").text).should == "Provider can accurately get directions from current location to appointment location"
      ($driver.find_element(:xpath, "//tr[7]/td").text).should == "Provider can get directions from custom start location to customer end location"
      ($driver.find_element(:xpath, "//tr[8]/td").text).should == "Provider can cancel appointment"
      ($driver.find_element(:xpath, "//tr[9]/td").text).should == "Provider can update current status of appointment"
      ($driver.find_element(:xpath, "//tr[10]/td").text).should == "Provider can logout"
      ($driver.find_element(:xpath, "//tr[11]/td").text).should == "Provider can delete an appointment"
      $driver.find_element(:link, "Sign out").click
      ($driver.find_element(:css, "img[alt=\"Outpost\"]").text).should == ""
      ($driver.find_element(:css, "h2.form-signin-heading").text).should == "Please Sign In"
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
