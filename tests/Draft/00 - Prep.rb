require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "00 - Test Prep/Cleanup" do
  
  before(:all) do
    print "** Starting: #{self.class.description} **"
  end

  before(:each) do |x|
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @tries = []
    $driver = start_driver()
    puts ""
    print "#{x.example.description}: "
  end
  
  after(:all) do
    # if this is really the end... then quit.
    puts ""
    puts "** Finished: #{self.class.description} **"
    unless $is_test_suite
      $driver.quit
    end
  end
  
  it "Delete main documents" do
    begin
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
      
      ensure_user_logs_out
    rescue => e
      if e.inspect.include?("Selenium::WebDriver::Error::UnknownError") || e.inspect.include?("has already finished")
        $driver = nil
        $driver = start_driver()
        e.ignore
      elsif e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      elsif e.inspect.include? 'id="IModalOverlay"'
        # For Draft, we have this pesky Intercom modal that causes issues. If we ever run into it, ignore it and just carry on.
        if $driver.find_element(:css, '.ic_close_modal').displayed?
          puts "Closed Intercom modal: #{$driver.find_element(:css, '.ic_close_modal').click}"
        end
        sleep(3)
        e.ignore
      elsif ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        retry
      end
      
      #raise
    end
  end
      
  it "Delete editor documents" do
    begin
      $driver.get(@base_url + 'documents')
      
      #$driver.find_element(:link, "LOGIN").click
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
      
      ensure_user_logs_out
    rescue => e
      if e.inspect.include?("Selenium::WebDriver::Error::UnknownError") || e.inspect.include?("has already finished")
        $driver = nil
        $driver = start_driver()
        e.ignore
      elsif e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      elsif e.inspect.include? 'id="IModalOverlay"'
        # For Draft, we have this pesky Intercom modal that causes issues. If we ever run into it, ignore it and just carry on.
        if $driver.find_element(:css, '.ic_close_modal').displayed?
          puts "Closed Intercom modal: #{$driver.find_element(:css, '.ic_close_modal').click}"
        end
        sleep(3)
        e.ignore
      elsif ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        retry
      end
      
      #raise
    end
  end
  
end
