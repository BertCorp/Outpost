require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Test Admin Can Complete Report" do

  before(:each) do
    @test_id = "35"
    start(@test_id)
    $driver = start_driver({ name: 'Outpost - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_4_test_admin_can_complete_report" do
    begin
      start_time = Time.now

      $driver.get(@base_url + "login")
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys "mark@outpostqa.com"
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "Testpost1"
      $driver.find_element(:xpath, "//button[@type='submit']").click
      ($driver.find_element(:xpath, "//body/div").text).should == "× Signed in successfully."
      ($driver.find_element(:link, "Admin").text).should == "Admin"
      $driver.find_element(:link, "Admin").click
      ($driver.find_element(:link, "*Test Company*").text).should =~ /^exact:[\s\S]*Test Company[\s\S]*$/
      ($driver.find_element(:xpath, "//td[3]").text).should == "Queued" }
      ($driver.find_element(:css, "input.btn.btn-success").attribute("value")).should == "Start Report"
      $driver.find_element(:css, "input.btn.btn-success").click
      ($driver.find_element(:css, "h2").text).should =~ /^exact:Report generated for [\s\S]*Test Company[\s\S]*$/
      ($driver.find_element(:name, "commit").attribute("value")).should == "Run This Report"
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:css, "p").text).should == "Current Status: Running" }
      ($driver.find_element(:xpath, "//p[6]").text).should == "Monitored By: Mark Bertrand"
       #= close_alert_and_get_its_text()
      $driver.find_element(:css, "input.btn.btn-success").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Passed").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[2]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[3]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[4]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[5]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[6]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[7]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[8]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[9]").text).should == "Passed"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:link, "Running").text).should == "Running"
      $driver.find_element(:css, "input.btn.btn-success").click
      $driver.find_element(:xpath, "//button[@type='button']").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:xpath, "(//a[contains(text(),'Passed')])[10]").text).should == "Passed"
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      ($driver.find_element(:css, "h2").text).should =~ /^exact:Report generated for [\s\S]*Test Company[\s\S]*$/
      ($driver.find_element(:css, "p").text).should == "Current Status: Completed"
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
