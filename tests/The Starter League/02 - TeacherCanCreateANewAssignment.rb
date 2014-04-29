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
      wait = Selenium::WebDriver::Wait.new(:timeout => 15) # seconds
      
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      
      # Add a new assignment
      $driver.find_element(:link, "Add a new assignment").click
      
      assignment_one = "Exercise #" + rand(10000).to_s
      
      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys assignment_one
      $driver.find_element(:name, "commit").click
      # Set wysiwyg editor + textarea text via javascript (minor hack)
      $driver.find_element(:css, ".redactor_editor").click
      $driver.find_element(:css, ".redactor_editor").send_keys "Test content for " + assignment_one
      $driver.execute_script("document.getElementsByClassName('redactor_editor')[0].innerHTML = '<p>Test content for " + assignment_one + "</p>'")
      $driver.execute_script("document.getElementById('assignment_task_content').innerHTML = '<p>Test content for " + assignment_one + "</p>'")
      sleep(1)
      $driver.find_element(:link, "Publish...").click
      $driver.find_element(:name, "publish_and_notify").click
      sleep(1)
      # Vertify
      ($driver.find_elements(:css, ".alert-danger").size).should == 0
      # Verify
      ($driver.find_element(:link, assignment_one).text).should == assignment_one
      $driver.find_element(:link, assignment_one).click
      
      wait.until { $driver.find_elements(:link, "← Assignments").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == assignment_one + "\n- change this"
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_one
      $driver.find_element(:link, "← Assignments").click
      wait.until { $driver.find_elements(:link, "Add a new assignment").size > 0 }
      
      # Add a new assigment
      $driver.find_element(:link, "Add a new assignment").click
      $driver.find_element(:id, "assignment_requires_submission_true").click

      assignment_two = "Exercise #" + rand(10000).to_s

      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys assignment_two
      $driver.find_element(:name, "commit").click
      # Set wysiwyg editor + textarea text via javascript (minor hack)
      $driver.find_element(:css, ".redactor_editor").click
      $driver.find_element(:css, ".redactor_editor").send_keys "Test content for " + assignment_two
      $driver.execute_script("document.getElementsByClassName('redactor_editor')[0].innerHTML = '<p>Test content for " + assignment_two + "</p>'")
      $driver.execute_script("document.getElementById('assignment_task_content').innerHTML = '<p>Test content for " + assignment_two + "</p>'")
      sleep(1)
      $driver.find_element(:link, "Publish...").click
      $driver.find_element(:name, "publish_and_notify").click
      # Verify
      ($driver.find_element(:link, assignment_two).text).should == assignment_two
      $driver.find_element(:link, assignment_two).click

      wait.until { $driver.find_elements(:link, "← Assignments").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == assignment_two + "\nrequires a submission (private) - change this"
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_two
      $driver.find_element(:link, "← Assignments").click
      wait.until { $driver.find_elements(:link, "Add a new assignment").size > 0 }
      
      # Double check that activity was logged.
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_one + "\"").text).should == "published assignment \"" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_two + "\"").text).should == "published assignment \"" + assignment_two + "\""
      # Check that activity was logged for logged in user.
      $driver.find_element(:link, "Me").click
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_one + "\"").text).should == "published assignment \"" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_two + "\"").text).should == "published assignment \"" + assignment_two + "\""
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end