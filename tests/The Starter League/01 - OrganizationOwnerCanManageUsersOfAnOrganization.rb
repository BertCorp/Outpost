require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Organization Owner Can Manage Users Of An Organization" do

  before(:all) do
    @test_id = "27"
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @tries = []
    start(@test_id)
  end
  
  after(:all) do
    # if this is really the end... then quit.
    unless $is_test_suite
      $driver.quit
      $outpost.quit if $outpost
    end
  end
  
  it "test_01_organization_owner_can_manage_users_of_an_organization" do
    begin
      $driver = start_driver({ :name => 'Starter League - Automated Tests', 'os' => 'OS X', 'os_version' => 'Mavericks' })
      $driver.manage.timeouts.implicit_wait = 3
      
      clear_gmail_inbox
      
      login_as_admin
      
      # Invite a new teacher
      $driver.find_element(:link, "People").click
      $wait.until { $driver.find_elements(:id, "add-people-btn").size > 0 }
      $driver.find_element(:id, "add-people-btn").click
      teacher_email = "test+lantern-t" + rand(1000).to_s + "@outpostqa.com"
      $driver.find_element(:id, "invitation_emails_").clear
      $driver.find_element(:id, "invitation_emails_").send_keys teacher_email
      $driver.find_element(:id, "invitation_staff").click
      $driver.find_element(:id, "invitation_enrollments_0_course_id").click
      $driver.find_element(:id, "invitation_enrollments_0_role").find_elements( :tag_name => "option" ).find do |option|
        option.text == "teacher"
      end.click
      $driver.find_element(:name, "commit").click

      ensure_user_logs_out
      
      sleep(5)
      sign_into_gmail
      
      wait_for_email
      
      $driver.find_elements(:css, "table td span b").find do |subject|
        subject.text == "You're invited to join Outpost"
      end.click
      # Copy and go to the invite link.
      if $driver.find_elements(:link, 'Click here to create your account').size < 1
        puts "Multiple emails potentially found! Trying to click expander image: #{$driver.find_elements(:css, "div[data-tooltip=\"Show trimmed content\"] img").size > 0}"
        $driver.find_element(:css, "div[data-tooltip=\"Show trimmed content\"] img").click
        puts "clicked. does link exist now? #{$driver.find_elements(:link, 'Click here to create your account').size > 0}"
      end
      teacher_invite_link = $driver.find_element(:link, 'Click here to create your account').attribute('href')
      puts "Teacher invite link: #{teacher_invite_link}"
      $driver.get teacher_invite_link
      if alert_present?
        close_alert_and_get_its_text(true)
      end
      $driver.get teacher_invite_link if $driver.current_url != teacher_invite_link
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
      # Verify
      ($driver.find_element(:css, "h4").text).should == "Outpost Teacher (" + teacher_email + ")"
      # Verify
      ($driver.find_element(:css, "section.enrollments > ul > li > a").text).should == "Outpost Test Class"
      
      ensure_user_logs_out

      clear_gmail_inbox

      login_as_admin
      
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "add-people-btn").click
      student_email = "test+lantern-s" + rand(1000).to_s + "@outpostqa.com"
      $driver.find_element(:id, "invitation_emails_").clear
      $driver.find_element(:id, "invitation_emails_").send_keys student_email
      $driver.find_element(:id, "invitation_enrollments_0_course_id").click
      $driver.find_element(:name, "commit").click
      
      ensure_user_logs_out
      
      sleep(5)
      sign_into_gmail
      
      wait_for_email
      
      $driver.find_elements(:css, "table td span b").find do |subject|
        subject.text == "You're invited to join Outpost"
      end.click
      # Copy and go to the invite link.
      if $driver.find_elements(:link, 'Click here to create your account').size < 1
        puts "Multiple emails potentially found! Trying to click expander image: #{$driver.find_elements(:css, "div[data-tooltip=\"Show trimmed content\"] img").size > 0}"
        $driver.find_element(:css, "div[data-tooltip=\"Show trimmed content\"] img").click
        puts "clicked. does link exist now? #{$driver.find_elements(:link, 'Click here to create your account').size > 0}"
      end
      student_invite_link = $driver.find_element(:link, 'Click here to create your account').attribute('href')
      puts "Student invite link: #{student_invite_link}"
      $driver.get student_invite_link
      if alert_present?
        close_alert_and_get_its_text(true)
      end
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
      # Verify
      ($driver.find_element(:css, "h4").text).should == "Outpost Student (" + student_email + ")"
      # Verify
      ($driver.find_element(:css, "h6").text).should == "You're a student in:"

      ensure_user_logs_out
      
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      # Verify
      ($driver.find_element(:link, "See an overview of your students' progress").text).should == "See an overview of your students' progress"
      $driver.find_element(:link, "See an overview of your students' progress").click
      $wait.until { $driver.find_elements(:link, "Go back").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == "Here's how your students are progressing in Outpost Test Class"
      # Verify
      ($driver.find_element(:link, "Student, Outpost").text).should == "Student, Outpost"
      $driver.find_element(:link, "Student, Outpost").click
      #$driver.find_element(:link, "Go back").click
      # Verify
      ($driver.find_element(:css, "#profile .user-details h4 a").text).should == student_email
      
      pass(@test_id)
    rescue => e
      # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="flash-msg"'
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually Browserstack's error, so let's wait a bit and then try again.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts ""
        puts "Retry due to Browserstack exception: #{e.inspect}"
        sleep(10)
        restart(@test_id)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.delete_if { |l| !l.include? '/tests/' }.join("\n") unless $is_test_suite
      puts "Retrying `#{self.class.description}`: #{@tries.count}"
      puts ""
      retry if @tries.count < 3 && $is_test_suite
      fail(@test_id, e)
    end
  end
  
end
