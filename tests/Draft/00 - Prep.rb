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
    unless $is_test_suite
      $driver.quit
    end
  end
  
  it "test_0_prep" do
    begin
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
        begin
          $driver.find_element(:css, ".document:nth-child(1) button.dropdown-toggle").click
          $driver.find_element(:css, '.document:nth-child(1) .dropdown-menu').find_element(:link, "DELETE DOCUMENT").click
          $driver.switch_to.alert.accept
          sleep(1)
        rescue
        end
        $driver.navigate.refresh
      end
      
      $driver.find_element(:link, "LOGOUT").click
      sleep(1)
      
      $driver.find_element(:link, "LOGIN").click
      $driver.find_element(:id, "draft_user_email").clear
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft_editor@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").clear
      $driver.find_element(:id, "draft_user_password").send_keys "testcase12"
      $driver.find_element(:name, "commit").click
      
      count = $driver.find_elements(:css, ".document button.dropdown-toggle").count
      count.times do
        begin
          $driver.find_element(:css, ".document:nth-child(1) button.dropdown-toggle").click
          $driver.find_element(:css, '.document:nth-child(1) .dropdown-menu').find_element(:link, "DELETE DOCUMENT").click
          $driver.switch_to.alert.accept
          sleep(1)
        rescue
        end
        $driver.navigate.refresh
      end
      
      $driver.find_element(:link, "LOGOUT").click
      sleep(1)

    rescue => e
      if e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      end
      # For Draft, we have this pesky Intercom modal that causes issues. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="IModalOverlay"'
        if $driver.find_element(:css, '.ic_close_modal').displayed?
          puts "Closed Intercom modal: #{$driver.find_element(:css, '.ic_close_modal').click}"
        end
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
      
      raise
    end
  end
  
end
