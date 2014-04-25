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
    login_as_admin
    
    # Delete Resources
    $driver.find_element(:link, "Classes").click
    $driver.find_element(:link, "Outpost Test Class").click
    $driver.find_element(:link, "Resources").click
    $driver.find_element(:link, "test_document.rtf").click
    $driver.find_element(:link, "Delete").click
    close_alert_and_get_its_text(true).should =~ /^Are you sure[\s\S]$/
    $driver.find_element(:link, "Document #" + document_two + " A written test resource body of cotent.").click
    $driver.find_element(:link, "Delete").click
    close_alert_and_get_its_text(true).should =~ /^Are you sure[\s\S]$/
    # Warning: verifyTextNotPresent may require manual changes
    # Veridy
    $driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*link=test_document\.rtf[\s\S]*$/
    # People Cleanup
    $driver.find_element(:link, "People").click
    # Verify
    ($driver.find_element(:link, "Outpost T.").text).should == "Outpost T."
    # Verify
    ($driver.find_element(:link, "Outpost S.").text).should == "Outpost S."
    $driver.find_element(:link, "Outpost T.").click
    $driver.find_element(:link, "Delete user").click
    (close_alert_and_get_its_text(true)).should == ""
    # Verify
    ($driver.find_element(:id, "flash-msg").text).should == "Outpost was successfully removed from Outpost×"
    $driver.find_element(:link, "Outpost S.").click
    $driver.find_element(:link, "Delete user").click
    (close_alert_and_get_its_text(true)).should == ""
    # Verify
    ($driver.find_element(:id, "flash-msg").text).should == "Outpost was successfully removed from Outpost×"
    # Warning: verifyTextNotPresent may require manual changes
    # Verify
    $driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*link=Outpost T\.[\s\S]*$/
    # Warning: verifyTextNotPresent may require manual changes
    # Verify
    $driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*link=Outpost S\.[\s\S]*$/
  end
  
end
