require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "TestPrep" do

  before(:all) do
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_0_prep" do
    begin
      start_time = Time.now
      
      $driver = start_driver({ name: 'Draft - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      
=begin
      $driver.get "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en"
      $driver.find_element(:id, "Email").clear
      $driver.find_element(:id, "Email").send_keys "test@bertcorp.com"
      $driver.find_element(:id, "Passwd").clear
      $driver.find_element(:id, "Passwd").send_keys "LigReb2013"
      $driver.find_element(:id, "signIn").click
      $driver.find_element(:css, "div[data-tooltip=\"Select\"] span").click

      delete_link = $driver.find_element(:css, "div[data-tooltip=\"Delete\"]")
      if delete_link.displayed? == true
        delete_link.click
      end

      $driver.find_element(:link, "test@bertcorp.com").click
      $driver.find_element(:link, "Sign out").click
=end
      start_logged_in
      
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
