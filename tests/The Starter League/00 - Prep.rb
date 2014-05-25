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
  
  it "Clean up users" do
    begin
      login_as_admin
      
      # People Cleanup
      click_link "People"
      # Leave one teacher account (and one admin) in the system.
      while $driver.find_elements(:css, '#teaching_staff li').size > 3 do
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
      while $driver.find_elements(:css, "#students li").size >= 3 do
        #puts "Students: " + $driver.find_elements(:css, '#students li').size.to_s
        #puts $driver.find_element(:link, "Outpost S.").attribute('href')
        # Verify
        click_link "Outpost S."
        $driver.find_element(:link, "Delete user").click
        (close_alert_and_get_its_text(true)).should include("Are you sure")
        # Verify
        ($driver.find_element(:id, "flash-msg").text).should include("was successfully removed")
        #$driver.navigate.back
      end
      
      # Verify
      $driver.find_element(:id, 'teaching_staff').find_elements(:link, "Outpost T.").size.should <= 2
      # Verify
      $driver.find_element(:id, 'students').find_elements(:link, "Outpost S.").size.should <= 2
      # Warning: verifyTextNotPresent may require manual changes
      #$driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*link=Outpost S\.[\s\S]*$/
    rescue => e
      # Ignore any modal windows that popped up that might be causing us an issue.
      if e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      end
      # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="flash-msg"'
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        #restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      raise
      #if @tries.count < 3 && $is_test_suite
      #  puts "Retrying `#{self.class.description}`: #{@tries.count}"
      #  puts ""
      #  retry
      #end
      #fail(@test_id, e)
    end 
  end
  
  it "Clean up pending invitations" do
    begin
      login_as_admin
      
      # Invitation Cleanup
      click_link "People"
      
      if $driver.find_elements(:id, 'pending-invitations-link').size > 0
        $driver.find_element(:id, 'pending-invitations-link').click
        $wait.until { $driver.find_elements(:link, "Delete").size > 0 }
        
        while $driver.find_elements(:link, "Delete").size > 0 do
          $driver.find_elements(:link, "Delete").first.click
          (close_alert_and_get_its_text(true)).should include("Are you sure")
          # Verify
          ($driver.find_element(:id, "flash-msg").text).should include("was successfully")
        end
      end
      click_link "People" unless $driver.current_url.include? '/people'
      # verify
      $driver.find_elements(:id, 'pending-invitations-link').size.should == 0
        
    rescue => e
      # Ignore any modal windows that popped up that might be causing us an issue.
      if e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      end
      # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="flash-msg"'
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        #restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      raise
      #if @tries.count < 3 && $is_test_suite
      #  puts "Retrying `#{self.class.description}`: #{@tries.count}"
      #  puts ""
      #  retry
      #end
      #fail(@test_id, e)
    end
  end

  it "Clean up assignments" do
    begin
      login_as_admin
      
      # go to assignments page
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Assignments"
      
      # loop through .assignment and leave the newest 10 
      #assignment_899 > td.title > a
      while $driver.find_elements(:css, '#assignments > .curriculum-items > tbody > tr').size > 10 do
        $driver.find_element(:css, '#assignments > .curriculum-items > tbody > tr:nth-child(1) > td.title > a').click
        click_link "change this"
        
        $wait.until { $driver.find_elements(:link, "Delete this assignment").size > 0 }
        $driver.find_element(:link, "Delete this assignment").click
        (close_alert_and_get_its_text(true)).should include("Are you sure")
        sleep(1)
        # Verify
        ($driver.find_element(:id, "flash-msg").text).should include("was successfuly deleted")

        click_link "Assignments"
      end
      # Verify
      $driver.find_elements(:css, '#assignments > .curriculum-items > tbody > tr').size.should <= 10

    rescue => e
      # Ignore any modal windows that popped up that might be causing us an issue.
      if e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      end
      # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="flash-msg"'
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        #restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      raise
      #if @tries.count < 3 && $is_test_suite
      #  puts "Retrying `#{self.class.description}`: #{@tries.count}"
      #  puts ""
      #  retry
      #end
      #fail(@test_id, e)
    end 
  end

  it "Clean up resources" do
    begin
      login_as_admin
      
      # Delete Resources
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Resources"
      
      # loop through .assignment and leave the newest 5
      while $driver.find_elements(:css, '#resources > table > tbody > tr').size > 5 do
        if $driver.find_elements(:css, '#resources > table > tbody > tr:nth-child(1) > td.content > a').size > 0
          $driver.find_element(:css, '#resources > table > tbody > tr:nth-child(1) > td.content > a').click
          $wait.until { $driver.find_elements(:link, "Delete").size > 0 }
          $driver.find_element(:link, "Delete").click
          (close_alert_and_get_its_text(true)).should include("Are you sure")
          if element_present?(:id, "flash-msg")
            ($driver.find_element(:id, "flash-msg").text).should include("was successfuly deleted")
          end
        end
        click_link "Resources" unless $driver.current_url.include? '/resources'
      end
      # Verify
      $driver.find_elements(:css, '#resources > table > tbody > tr').size.should <= 5
      
    rescue => e
      # Ignore any modal windows that popped up that might be causing us an issue.
      if e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      end
      # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="flash-msg"'
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        #restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      raise
      #if @tries.count < 3 && $is_test_suite
      #  puts "Retrying `#{self.class.description}`: #{@tries.count}"
      #  puts ""
      #  retry
      #end
      #fail(@test_id, e)
    end 
  end
  
  it "Clean up discussions" do
    begin
      #ensure_user_logs_out
      login_as_admin
      
      # Delete Resources
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Discussions"      
      # loop through .assignment and leave the newest 5
      # #course-content > table > tbody > tr:nth-child(6)
      while $driver.find_elements(:css, '#course-content > .discussions-table > tbody > tr').size > 5 do
        if $driver.find_elements(:css, '#course-content > .discussions-table > tbody > tr:nth-child(6) > td.content > a').size > 0
          $driver.find_element(:css, '#course-content > .discussions-table > tbody > tr:nth-child(6) > td.content > a').click
          $wait.until { $driver.find_elements(:link, "Delete").size > 0 }
          $driver.find_element(:link, "Delete").click
          sleep(1)
          (close_alert_and_get_its_text(true)).should include("Are you sure")
          if element_present?(:id, "flash-msg")
            ($driver.find_element(:id, "flash-msg").text).should include("was successfuly deleted")
          end
        end
        click_link "Discussions" unless $driver.current_url.include? "/discussions"
      end
      # Verify
      $driver.find_elements(:css, '#course-content > .discussions-table > .tbody > tr').size.should <= 5
            
    rescue => e
      # Ignore any modal windows that popped up that might be causing us an issue.
      if e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      end
      # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="flash-msg"'
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        #restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      raise
      #if @tries.count < 3 && $is_test_suite
      #  puts "Retrying `#{self.class.description}`: #{@tries.count}"
      #  puts ""
      #  retry
      #end
      #fail(@test_id, e)
    end 
  end

end
