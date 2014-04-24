require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Organization Owner Can Manage Users Of An Organization" do

  before(:each) do
    @test_id = "27"
    start(@test_id)
    $driver = start_driver({ name: 'Starter League - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_01_organization_owner_can_manage_users_of_an_organization" do
    begin
      start_time = Time.now
      $driver.get(@base_url)
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys "test@outpostqa.com"
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "LigReb2013"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "add-people-btn").click
      # ERROR: Caught exception [ERROR: Unsupported command [getEval |  | ]]
      $driver.find_element(:id, "invitation_emails_").clear
      $driver.find_element(:id, "invitation_emails_").send_keys teacher_email
      $driver.find_element(:id, "invitation_staff").click
      $driver.find_element(:id, "invitation_enrollments_0_course_id").click
      # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Logout").click
      $driver.get "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en"
      # ERROR: Caught exception [unknown command [tryClick]]
      $driver.find_element(:id, "Email").clear
      $driver.find_element(:id, "Email").send_keys "test@bertcorp.com"
      $driver.find_element(:id, "Passwd").clear
      $driver.find_element(:id, "Passwd").send_keys "LigReb2013"
      $driver.find_element(:id, "signIn").click
      $driver.find_element(:css, "span:contains(\"You're invited to join Outpost\"):first").click
      teacher_invitation_link = $driver.find_element(:css, "a:contains(\"Click here to create your account\")").attribute("href")
      p teacher_invitation_link
      $driver.get(@base_url + teacher_invitation_link)
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
      $driver.find_element(:link, "Logout").click
      $driver.get "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en"
      $driver.find_element(:id, "Email").clear
      $driver.find_element(:id, "Email").send_keys "test@bertcorp.com"
      $driver.find_element(:id, "Passwd").clear
      $driver.find_element(:id, "Passwd").send_keys "LigReb2013"
      $driver.find_element(:id, "signIn").click
      $driver.find_element(:css, "div[data-tooltip=\"Select\"] span").click
      # ERROR: Caught exception [ERROR: Unsupported command [keyPress | css=div[data-tooltip="Delete"] | #]]
      $driver.find_element(:link, "Sign out").click
      $driver.get(@base_url)
      # ERROR: Caught exception [unknown command [tryClick]]
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys "test@outpostqa.com"
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "LigReb2013"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "add-people-btn").click
      # ERROR: Caught exception [ERROR: Unsupported command [getEval |  | ]]
      $driver.find_element(:id, "invitation_emails_").clear
      $driver.find_element(:id, "invitation_emails_").send_keys student_email
      $driver.find_element(:id, "invitation_enrollments_0_course_id").click
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Logout").click
      $driver.get "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en"
      $driver.find_element(:id, "Email").clear
      $driver.find_element(:id, "Email").send_keys "test@bertcorp.com"
      $driver.find_element(:id, "Passwd").clear
      $driver.find_element(:id, "Passwd").send_keys "LigReb2013"
      $driver.find_element(:id, "signIn").click
      $driver.find_element(:css, "span:contains(\"You're invited to join Outpost\"):first").click
      student_invitation_link = $driver.find_element(:css, "a:contains(\"Click here to create your account\")").attribute("href")
      p student_invitation_link
      $driver.get(@base_url + student_invitation_link)
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
      $driver.find_element(:link, "Logout").click
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys "test@outpostqa.com"
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "LigReb2013"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      # Verify
      ($driver.find_element(:link, "See an overview of your students' progress").text).should == "See an overview of your students' progress"
      $driver.find_element(:link, "See an overview of your students' progress").click
      # Verify
      ($driver.find_element(:css, "h5").text).should == "Here's how your students are progressing in Outpost Test Class"
      # Verify
      ($driver.find_element(:link, "Student, Outpost").text).should == "Student, Outpost"
      $driver.find_element(:link, "Go back").click
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
