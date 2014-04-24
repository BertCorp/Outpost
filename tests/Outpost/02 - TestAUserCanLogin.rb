require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Test A User Can Login" do

  before(:each) do
    @test_id = "33"
    start(@test_id)
    $driver = start_driver({ name: 'Outpost - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_2_test_a_user_can_login" do
    begin
      start_time = Time.now
      $driver.get(@base_url)
      ($driver.find_element(:css, "img[alt=\"Outpost\"]").text).should == ""
      $driver.get(@base_url + "login")
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys "mark+demo@outpostqa.com"
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "changeme"
      $driver.find_element(:xpath, "//button[@type='submit']").click
      ($driver.find_element(:xpath, "//body/div").text).should == "× Signed in successfully."
      ($driver.find_element(:link, "Dashboard").text).should == "Dashboard"
      ($driver.find_element(:link, "Past Reports").text).should == "Past Reports"
      ($driver.find_element(:link, "Your Tests").text).should == "Your Tests"
      ($driver.find_element(:link, "Your Account").text).should == "Your Account"
      ($driver.find_element(:link, "Sign out").text).should == "Sign out"
      ($driver.find_element(:name, "commit").attribute("value")).should == "Run Your Tests!"
      ($driver.find_element(:css, "h3").text).should == "Your Tests"
      ($driver.find_element(:css, "td").text).should == "Provider can login using username/password combination of demo/demo"
      ($driver.find_element(:xpath, "//tr[3]/td").text).should == "Provider can add new appointment"
      ($driver.find_element(:xpath, "//tr[4]/td").text).should == "Provider can search for a specific appointment by customer name or phone number"
      ($driver.find_element(:xpath, "//tr[5]/td").text).should == "Provider can edit appointment"
      ($driver.find_element(:xpath, "//tr[6]/td").text).should == "Provider can accurately get directions from current location to appointment location"
      ($driver.find_element(:xpath, "//tr[7]/td").text).should == "Provider can get directions from custom start location to customer end location"
      ($driver.find_element(:xpath, "//tr[8]/td").text).should == "Provider can cancel appointment"
      ($driver.find_element(:xpath, "//tr[9]/td").text).should == "Provider can update current status of appointment"
      ($driver.find_element(:xpath, "//tr[9]/td").text).should == "Provider can update current status of appointment"
      ($driver.find_element(:xpath, "//tr[10]/td").text).should == "Provider can logout"
      ($driver.find_element(:xpath, "//tr[11]/td").text).should == "Provider can delete an appointment"
      ($driver.find_element(:xpath, "//div[3]/h3").text).should == "Last 5 Reports"
      ($driver.find_element(:link, "View All Your Reports").text).should == "View All Your Reports"
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
