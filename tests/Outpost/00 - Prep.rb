require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "TestPrep" do

  before(:each) do
    $driver = start_driver({ name: 'Draft - Automated Tests' })
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_0_prep" do
    $driver.get(@base_url)
    # ERROR: Caught exception [unknown command [tryClick]]
    # Verify
    ($driver.find_element(:css, "img[alt=\"Outpost\"]").text).should == ""
    
    $driver.get @base_url
    # ERROR: Caught exception [unknown command [tryClick]]
    # Verify
    ($driver.find_element(:css, "img[alt=\"Outpost\"]").text).should == ""
    $driver.find_element(:link, "Login").click
    $driver.find_element(:id, "user_email").clear
    $driver.find_element(:id, "user_email").send_keys "mark@outpostqa.com"
    $driver.find_element(:id, "user_password").clear
    $driver.find_element(:id, "user_password").send_keys "Testpost1"
    $driver.find_element(:xpath, "//button[@type='submit']").click
    $driver.find_element(:link, "Admin").click
    $driver.find_element(:link, "Home").click
    $driver.find_element(:css, "input.btn.btn-success").click
    $driver.find_element(:link, "Edit").click
    $driver.find_element(:link, "Delete Report").click
    close_alert_and_get_its_text(true).should =~ /^Are you sure you want to delete this report and its results[\s\S]$/
    $driver.find_element(:link, "Sign out").click
  end
  
end
