require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Test Cleanup" do

  before(:all) do
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @retry_count = 0
    $driver = start_driver({ name: 'Starter League - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit
    $outpost.quit if $outpost
  end
  
  it "Clean up users" do
    begin
      login_as_admin
      
      # People Cleanup
      $driver.find_element(:link, "People").click
      # Leave one teacher account (and one admin) in the system.
      while $driver.find_elements(:css, '#teaching_staff li').size > 2 do
        #puts "Teachers: " + $driver.find_elements(:css, '#teaching_staff li').size.to_s
        #puts $driver.find_element(:id, 'teaching_staff').find_element(:link, "Outpost T.").attribute('href')
        # Verify
        $driver.find_element(:id, 'teaching_staff').find_element(:link, "Outpost T.").click
        $driver.find_element(:link, "Delete user").click
        (close_alert_and_get_its_text(true)).should include("Are you sure")
        # Verify
        ($driver.find_element(:id, "flash-msg").text).should include("was successfully removed")
        #$driver.navigate.back      
      end
      # Leave one student account in the system.
      while $driver.find_elements(:css, "#students li").size >= 2 do
        #puts "Students: " + $driver.find_elements(:css, '#students li').size.to_s
        #puts $driver.find_element(:link, "Outpost S.").attribute('href')
        # Verify
        $driver.find_element(:link, "Outpost S.").click
        $driver.find_element(:link, "Delete user").click
        (close_alert_and_get_its_text(true)).should include("Are you sure")
        # Verify
        ($driver.find_element(:id, "flash-msg").text).should include("was successfully removed")
        #$driver.navigate.back
      end
      
      # Verify
      $driver.find_element(:id, 'teaching_staff').find_elements(:link, "Outpost T.").size <= 1
      # Verify
      $driver.find_element(:id, 'students').find_elements(:link, "Outpost S.").size <= 1
      # Warning: verifyTextNotPresent may require manual changes
      #$driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*link=Outpost S\.[\s\S]*$/
    rescue => e
      #@retry_count = @retry_count + 1
      puts ""
      puts "Current Page: #{$driver.current_url}"
      puts "Clean up users exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      puts ""
      #puts "Retry: #{@retry_count}"
      #retry if @retry_count < 3
    end 
  end

  it "Clean up assignments" do
    begin
      login_as_admin
      
      # go to assignments page
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Assignments").click
      $wait.until { $driver.current_url.include? '/assignments' }
      
      # loop through .assignment and leave the newest 10 
      while $driver.find_elements(:css, '#resources > table > tbody > tr').size > 10 do
        $driver.find_element(:css, '#resources > table > tbody > tr:nth-child(1) > td.content > a').click
        $wait.until { $driver.find_elements(:link, "change this").size > 0 }
        $driver.find_element(:link, "change this").click
        $driver.find_element(:link, "Delete this assignment").click
        (close_alert_and_get_its_text(true)).should include("Are you sure")
        # Verify
        ($driver.find_element(:id, "flash-msg").text).should include("was successfuly deleted")
        $driver.find_element(:link, "Assignments").click
        $wait.until { $driver.current_url.include? '/assignments' }
      end
      # Verify
      $driver.find_elements(:css, '#resources > table > tbody > tr').size <= 10

    rescue => e
      #@retry_count = @retry_count + 1
      puts ""
      puts "Current Page: #{$driver.current_url}"
      puts "Clean up assignments exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      puts ""
      #puts "Retry: #{@retry_count}"
      #raise
      #retry if @retry_count < 3
    end 
  end

  it "Clean up resources" do
    begin
      $driver.find_element(:link, "Logout").click if element_present?(:link, "Logout")
      $driver.find_element(:link, "Logout").click if element_present?(:link, "Logout")
      login_as_admin
      
      # Delete Resources
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $wait.until { $driver.current_url.include? '/resources' }
      
      # loop through .assignment and leave the newest 5
      while $driver.find_elements(:css, '#resources > table > tbody > tr').size > 5 do
        $driver.find_element(:css, '#resources > table > tbody > tr:nth-child(1) > td.content > a').click
        $wait.until { $driver.find_elements(:link, "Delete").size > 0 }
        $driver.find_element(:link, "Delete").click
        (close_alert_and_get_its_text(true)).should include("Are you sure")
        if element_present?(:id, "flash-msg")
          ($driver.find_element(:id, "flash-msg").text).should include("was successfuly deleted")
        end
        $driver.find_element(:link, "Resources").click
        $wait.until { $driver.current_url.include? '/resources' }
      end
      # Verify
      $driver.find_elements(:css, '#resources > table > tbody > tr').size <= 5
      
    rescue => e
      #@retry_count = @retry_count + 1
      puts ""
      puts "Current Page: #{$driver.current_url}"
      puts "Clean up resources exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      puts ""
      #puts "Retry: #{@retry_count}"
      #raise
      #retry if @retry_count < 3
    end 
  end
  
  it "Clean up discussions" do
    begin
      login_as_admin
      
      # Delete Resources
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Discussions").click
      $wait.until { $driver.current_url.include? '/discussions' }
      
      # loop through .assignment and leave the newest 5
      # #course-content > table > tbody > tr:nth-child(6)
      while $driver.find_elements(:css, '#course-content > .discussions-table > tbody > tr').size > 5 do
        $driver.find_element(:css, '#course-content > .discussions-table > tbody > tr:nth-child(6) > td.content > a').click
        $wait.until { $driver.find_elements(:link, "Delete").size > 0 }
        $driver.find_element(:link, "Delete").click
        (close_alert_and_get_its_text(true)).should include("Are you sure")
        if element_present?(:id, "flash-msg")
          ($driver.find_element(:id, "flash-msg").text).should include("was successfuly deleted")
        end
        $driver.find_element(:link, "Discussions").click
        $wait.until { $driver.current_url.include? '/discussions' }
      end
      # Verify
      $driver.find_elements(:css, '#course-content > .discussions-table > .tbody > tr').size <= 5
      
    rescue => e
      #@retry_count = @retry_count + 1
      puts ""
      puts "Current Page: #{$driver.current_url}"
      puts "Clean up discussions exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      puts ""
      #puts "Retry: #{@retry_count}"
      #raise
      #retry if @retry_count < 3
    end 
  end

end
