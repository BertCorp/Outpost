require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "01 - Organization Owner Can Manage Users Of An Organization" do

  before(:all) do
    @test_id = "27"
    print "** Starting: #{self.class.description} (Test ##{@test_id}) **"
  end

  before(:each) do |x|
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @tries = []
    $driver = start_driver()
    start(@test_id)    
    puts ""
    puts "#{x.example.description}"
  end
  
  after(:all) do
    # if this is really the end... then quit.
    puts ""
    puts "** Finished: #{self.class.description} **"
    unless $is_test_suite
      $driver.quit
    end
  end
  
  it "Manage Users of an Organization" do
    begin
      clear_gmail_inbox
      
      login_as_admin
      
      # Invite a new teacher
      print "Invite teacher: "
      click_link "People"
      $wait.until { $driver.find_elements(:id, "add-people-btn").size > 0 }
      $driver.find_element(:id, "add-people-btn").click
      teacher_email = "test+lantern-t" + rand(10000).to_s + "@outpostqa.com"
      puts teacher_email
      $driver.find_element(:id, "invitation_emails_").clear
      $driver.find_element(:id, "invitation_emails_").send_keys teacher_email
      $driver.find_element(:id, "invitation_staff").click
      $driver.find_element(:id, "invitation_enrollments_0_course_id").click
      $driver.find_element(:id, "invitation_enrollments_0_role").find_elements( :tag_name => "option" ).find do |option|
        option.text == "teacher"
      end.click
      $driver.find_element(:name, "commit").click

      ensure_user_logs_out
      
      teacher_invite_link = nil
      while teacher_invite_link == nil
        sleep(5)
        sign_into_gmail

        wait_for_email

        $driver.find_elements(:css, "table.F > tbody > tr > td span").find do |subject|
          subject.text == "You're invited to join Outpost"
        end.click
        # Copy and go to the invite link.
        if $driver.find_elements(:link, 'Click here to create your account').size < 1
          puts "Multiple emails potentially found! Trying to click expander image: #{$driver.find_elements(:css, "div[data-tooltip=\"Show trimmed content\"] img").size > 0}"
          $driver.find_element(:css, "div[data-tooltip=\"Show trimmed content\"] img").click
          puts "clicked. does link exist now? #{$driver.find_elements(:link, 'Click here to create your account').size > 0}"
        end
        teacher_invite_link = $driver.find_element(:link, 'Click here to create your account').attribute('href')

        if teacher_invite_link == nil
          puts "Teacher invite link is missing! Try again."
        end
      end
      
      print "Teacher accepted invite: "
      $driver.get teacher_invite_link
      close_alert_and_get_its_text(true)
      $driver.find_element(:id, "user_first_name").clear
      $driver.find_element(:id, "user_first_name").send_keys "Outpost"
      $driver.find_element(:id, "user_last_name").clear
      $driver.find_element(:id, "user_last_name").send_keys "Teacher"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:id, "user_terms_of_service").click
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }

      # Verify
      ($driver.find_element(:css, "h4").text).should == "Outpost Teacher (" + teacher_email + ")"
      # Verify
      puts ($driver.find_element(:css, "section.enrollments > ul > li > a").text).should == "Outpost Test Class"
      
      ensure_user_logs_out

      clear_gmail_inbox

      login_as_admin
      
      print "Invite student: "
      click_link "People"
      $driver.find_element(:id, "add-people-btn").click
      student_email = "test+lantern-s" + rand(10000).to_s + "@outpostqa.com"
      puts student_email
      $driver.find_element(:id, "invitation_emails_").clear
      $driver.find_element(:id, "invitation_emails_").send_keys student_email
      $driver.find_element(:id, "invitation_enrollments_0_course_id").click
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      ensure_user_logs_out
      
      student_invite_link = nil
      while student_invite_link == nil
        sleep(5)
        sign_into_gmail

        wait_for_email

        $driver.find_elements(:css, "table.F > tbody > tr > td span").find do |subject|
          subject.text == "You're invited to join Outpost"
        end.click
        # Copy and go to the invite link.
        if $driver.find_elements(:link, 'Click here to create your account').size < 1
          puts "Multiple emails potentially found! Trying to click expander image: #{$driver.find_elements(:css, "div[data-tooltip=\"Show trimmed content\"] img").size > 0}"
          $driver.find_element(:css, "div[data-tooltip=\"Show trimmed content\"] img").click
          puts "clicked. does link exist now? #{$driver.find_elements(:link, 'Click here to create your account').size > 0}"
        end
        student_invite_link = $driver.find_element(:link, 'Click here to create your account').attribute('href')

        if student_invite_link == nil
          puts "Student invite link is missing! Try again."
        end
      end
      
      print "Student accepted invite: "
      $driver.get student_invite_link
      close_alert_and_get_its_text(true)
      $driver.get student_invite_link if $driver.current_url != student_invite_link
      $driver.find_element(:id, "user_first_name").clear
      $driver.find_element(:id, "user_first_name").send_keys "Outpost"
      $driver.find_element(:id, "user_last_name").clear
      $driver.find_element(:id, "user_last_name").send_keys "Student"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:id, "user_terms_of_service").click
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      # Verify
      puts ($driver.find_element(:css, "h4").text).should == "Outpost Student (" + student_email + ")"
      # Verify
      ($driver.find_element(:css, "h6").text).should == "You're a student in:"

      ensure_user_logs_out
      
      login_as_admin
      
      print "Confirming with admin: "
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      ($driver.find_element(:link, "See an overview of your students' progress").text).should == "See an overview of your students' progress"

      click_link "See an overview of your students' progress"
      sleep(2)
      # Verify
      ($driver.find_element(:css, "h5").text).should == "Here's how your students are progressing in Outpost Test Class"
      # Verify
      ($driver.find_elements(:link, "Student, Outpost").size).should >= 3
      
      pass(@test_id)
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
