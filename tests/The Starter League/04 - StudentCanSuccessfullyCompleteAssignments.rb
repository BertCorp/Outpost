require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Student Can Successfully Complete Assignments" do

  before(:all) do
    @test_id = "30"
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @retry_count = 0
    start(@test_id)
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_04_student_can_successfully_complete_assignments_html" do
    begin
      $driver = start_driver({ name: 'Starter League - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      
      $driver.get(@base_url)
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "h4").text).should == "Outpost Student (" + student_email + ")"
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Exercise #" + assignment_one).click
      $driver.find_element(:name, "complete").click
      # Verify
      ($driver.find_element(:css, "span.done.reviewed").text).should == ""
      $driver.find_element(:link, "Exercise #" + assignment_two).click
      # ERROR: Caught exception [ERROR: Unsupported command [getEval |  | ]]
      $driver.find_element(:css, "textarea#assignment_submission_content").clear
      $driver.find_element(:css, "textarea#assignment_submission_content").send_keys "This is my first answer to a Lantern exercise. I hope I get it right! ", answer_one
      $driver.find_element(:name, "draft").click
      $driver.find_element(:link, "← Assignments").click
      $driver.find_element(:link, "Exercise #" + assignment_two).click
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for Exercise #" + assignment_two
      $driver.find_element(:css, "textarea#assignment_submission_content").clear
      $driver.find_element(:css, "textarea#assignment_submission_content").send_keys "This is my first answer to a Lantern exercise. I hope I get it right! ", assignment_two, " Now with a change to it!"
      $driver.find_element(:name, "complete").click
      $driver.find_element(:link, "Exercise #" + assignment_two).click
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      ($driver.find_element(:css, "div.review-grade > span").text).should == "Your answer is pending review."
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "answered Exercise #" + assignment_two).text).should == "answered Exercise #" + assignment_two
      # Verify
      ($driver.find_element(:link, "completed Exercise #" + assignment_one).text).should == "completed Exercise #" + assignment_one
      $driver.find_element(:link, "Me").click
      # Verify
      ($driver.find_element(:link, "answered Exercise #" + assignment_two).text).should == "answered Exercise #" + assignment_two
      # Verify
      ($driver.find_element(:link, "completed Exercise #" + assignment_one).text).should == "completed Exercise #" + assignment_one
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
      # Verify
      ($driver.find_element(:css, "td.completed").text).should == "Completed"
      # Verify
      ($driver.find_element(:link, "Pending review").text).should == "Pending review"
      $driver.find_element(:link, "Go back").click
      $driver.find_element(:link, "Logout").click
      
      pass(@test_id)
    rescue => e
      @retry_count = @retry_count + 1
      puts ""
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      puts "Retry: #{@retry_count}"
      puts ""
      retry if @retry_count < 3
      fail(@test_id, e)
    end
  end
  
end
