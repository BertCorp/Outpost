require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Teacher Can Create A New Assignment" do

  before(:each) do
    @test_id = "28"
    start(@test_id)
    $driver = start_driver({ name: 'Starter League - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_02_teacher_can_create_a_new_assignment" do
    begin
      start_time = Time.now
      $driver.get(@base_url)
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Add a new assignment").click
      # ERROR: Caught exception [ERROR: Unsupported command [getEval |  | ]]
      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys "Exercise #", assignment_one
      $driver.find_element(:name, "commit").click
      $driver.find_element(:css, "textarea#assignment_task_content").clear
      $driver.find_element(:css, "textarea#assignment_task_content").send_keys "Test content for Exercise #", assignment_one
      $driver.find_element(:link, "Publish...").click
      $driver.find_element(:name, "publish_and_notify").click
      # Verify
      ($driver.find_element(:link, "Exercise #" + assignment_one).text).should == "Exercise #" + assignment_one
      $driver.find_element(:link, "Exercise #" + assignment_one).click
      # Verify
      ($driver.find_element(:css, "h5").text).should == "Exercise #" + assignment_one + " \n - change this"
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for Exercise #" + assignment_one
      $driver.find_element(:link, "← Assignments").click
      $driver.find_element(:link, "Add a new assignment").click
      $driver.find_element(:id, "assignment_requires_submission_true").click
      # ERROR: Caught exception [ERROR: Unsupported command [getEval |  | ]]
      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys "Exercise #", assignment_two
      $driver.find_element(:name, "commit").click
      $driver.find_element(:css, "textarea#assignment_task_content").clear
      $driver.find_element(:css, "textarea#assignment_task_content").send_keys "Test content for Exercise #", assignment_two
      $driver.find_element(:link, "Publish...").click
      $driver.find_element(:name, "publish_and_notify").click
      # Verify
      ($driver.find_element(:link, "Exercise #" + assignment_two).text).should == "Exercise #" + assignment_two
      $driver.find_element(:link, "Exercise #" + assignment_two).click
      # Verify
      ($driver.find_element(:css, "h5").text).should == "Exercise #" + assignment_two + " \n requires a submission (private) - change this"
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for Exercise #" + assignment_two
      $driver.find_element(:link, "← Assignments").click
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "published assignment \"Exercise #" + assignment_one + "\"").text).should == "published assignment \"Exercise #" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"Exercise #" + assignment_two + "\"").text).should == "published assignment \"Exercise #" + assignment_two + "\""
      $driver.find_element(:link, "Me").click
      # Verify
      ($driver.find_element(:link, "published assignment \"Exercise #" + assignment_one + "\"").text).should == "published assignment \"Exercise #" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"Exercise #" + assignment_two + "\"").text).should == "published assignment \"Exercise #" + assignment_two + "\""
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
