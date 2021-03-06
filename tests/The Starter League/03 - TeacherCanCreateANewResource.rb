require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "03 - Teacher Can Add Resources" do
  
  before(:all) do
    @test_id = "29"
    print "** Starting: #{self.class.description} (Test ##{@test_id}) **"
  end

  before(:each) do |x|
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @tries = []
    $driver = start_driver()
    start(@test_id)    
    puts ""
    print "#{x.example.description}"
  end
  
  after(:all) do
    # if this is really the end... then quit.
    puts ""
    puts "** Finished: #{self.class.description} **"
    unless $is_test_suite
      $driver.quit
    end
  end
  
  it "Teacher Can Upload Resource" do
    begin
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Resources"
      sleep(1)
      $driver.find_element(:css, "#resources .left").find_element(:link, "File").click
      sleep(1)
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      $driver.execute_script("document.getElementById('attachment_file').style.height = 'auto';")
      $driver.execute_script("document.getElementById('attachment_file').style.width = 'auto';")

      begin
        $driver.find_element(:id, "attachment_file").send_keys "~/Documents/logger.js"
      rescue
        $driver.find_element(:id, "attachment_file").send_keys "/Users/chef/appium/logger.js"        
      end
      
      document_one = "Resource #" + rand(10000).to_s
      print " (#{document_one}): "
      type_redactor_field('resource_content', "An uploaded test resource. " + document_one)
      
      while $driver.find_elements(:css, ".actions > .buttons > button:nth-child(2)").size > 0 do
        $driver.find_element(:css, ".actions > .buttons > button:nth-child(2)").click
        sleep(1)
      end
      $wait.until { $driver.find_elements(:css, '.title').size > 0 }
      # Verify
      ($driver.find_element(:css, ".title").text).should == "logger.js"
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "logger.js (1.31 KB)\nAn uploaded test resource. " + document_one
    rescue => e
      if e.inspect.include?("Selenium::WebDriver::Error::UnknownError") || e.inspect.include?("has already finished")
        $driver = nil
        $driver = start_driver()
        e.ignore
      elsif e.inspect.include? 'UnhandledAlertError'
        # Ignore any modal windows that popped up that might be causing us an issue.
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      elsif e.inspect.include? 'StaleElementReferenceError'
        # Sometimes our timing is off. Chill for a second.
        sleep(2)
        e.ignore
      elsif e.inspect.include? 'class="flash-msg"'
        # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      if @tries.count < 3 && $is_test_suite
        puts "Retrying `#{self.class.description}`: #{@tries.count}"
        puts ""
        retry
      end
      fail(@test_id, e)
    end
  end
    
  it "Teacher Can Create Resource" do
    begin
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Resources"
      sleep(1)
      click_link "Text document"
      
      document_two = "Resource #" + rand(10000).to_s
      print " (#{document_two}): "
      
      $driver.find_element(:id, "resource_title").clear
      $driver.find_element(:id, "resource_title").send_keys document_two
      #$driver.find_element(:css, "textarea.resource-content").clear
      #$driver.find_element(:css, "textarea.resource-content").send_keys "A written test resource body of content."
      type_redactor_field('resource_content', "A written test resource body of content.")      
      
      while $driver.find_elements(:css, ".actions > .buttons > button:nth-child(2)").size > 0 do
        $driver.find_element(:css, ".actions > .buttons > button:nth-child(2)").click
        sleep(1)
      end
      $wait.until { $driver.find_elements(:css, '.title').size > 0 }

      # Verify
      ($driver.find_element(:css, ".title").text).should == document_two
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "A written test resource body of content."
      click_link "Resources"
      $wait.until { $driver.find_elements(:link, 'logger.js').size > 0 }
      # Verify
      ($driver.find_element(:link, "logger.js").text).should == "logger.js"
      # Verify
      ($driver.find_element(:link, document_two + " A written test resource body of content.").text).should == document_two + " A written test resource body of content."
      click_link "Recent Activity"
      # Verify
      ($driver.find_element(:link, "added resource \"logger.js\" in \"Outpost Test Class\"").text).should == "added resource \"logger.js\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"" + document_two + "\" in \"Outpost Test Class\""
      click_link "Me"
      # Verify
      ($driver.find_element(:link, "added resource \"logger.js\" in \"Outpost Test Class\"").text).should == "added resource \"logger.js\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"" + document_two + "\" in \"Outpost Test Class\""
      
      pass(@test_id)
    rescue => e
      if e.inspect.include?("Selenium::WebDriver::Error::UnknownError") || e.inspect.include?("has already finished")
        $driver = nil
        $driver = start_driver()
        e.ignore
      elsif e.inspect.include? 'UnhandledAlertError'
        # Ignore any modal windows that popped up that might be causing us an issue.
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      elsif e.inspect.include? 'StaleElementReferenceError'
        # Sometimes our timing is off. Chill for a second.
        sleep(2)
        e.ignore
      elsif e.inspect.include? 'class="flash-msg"'
        # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      if @tries.count < 3 && $is_test_suite
        puts "Retrying `#{self.class.description}`: #{@tries.count}"
        puts ""
        retry
      end
      fail(@test_id, e)
    end
  end
  
end
