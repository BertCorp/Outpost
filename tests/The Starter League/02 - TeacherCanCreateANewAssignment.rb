require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Teacher Can Create A New Assignment" do

  before(:all) do
    @test_id = "28"
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
  
  it "test_02_teacher_can_create_a_new_assignment" do
    begin
      $driver = start_driver({ :name => 'Starter League - Automated Tests', 'os' => 'OS X', 'os_version' => 'Mavericks' })
      $driver.manage.timeouts.implicit_wait = 3
      
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      
      # Add a new completion assignment
      $driver.find_element(:link, "Add a new assignment").click
      
      assignment_one = "Completion Exercise #" + rand(10000).to_s
      
      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys assignment_one
      $driver.find_element(:name, "commit").click
      
      type_redactor_field('assignment_task_content', "Test content for " + assignment_one)
      
      $driver.find_element(:link, "Publish...").click
      $driver.find_element(:name, "publish_and_notify").click
      sleep(1)
      # Vertify
      ($driver.find_elements(:css, ".alert-danger").size).should == 0
      # Verify
      ($driver.find_element(:link, assignment_one).text).should == assignment_one
      $driver.find_element(:link, assignment_one).click
      
      $wait.until { $driver.find_elements(:link, "← Assignments").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == assignment_one + "\n- change this"
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_one
      $driver.find_element(:link, "← Assignments").click
      $wait.until { $driver.find_elements(:link, "Add a new assignment").size > 0 }
      
      # Add a new submission assigment
      $driver.find_element(:link, "Add a new assignment").click
      $driver.find_element(:id, "assignment_requires_submission_true").click

      assignment_two = "Submission Exercise #" + rand(10000).to_s

      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys assignment_two
      $driver.find_element(:name, "commit").click

      type_redactor_field('assignment_task_content', "Test content for " + assignment_two)

      $driver.find_element(:link, "Publish...").click
      $driver.find_element(:name, "publish_and_notify").click
      # Verify
      ($driver.find_element(:link, assignment_two).text).should == assignment_two
      $driver.find_element(:link, assignment_two).click

      $wait.until { $driver.find_elements(:link, "← Assignments").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == assignment_two + "\nrequires a submission (private) - change this"
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_two
      $driver.find_element(:link, "← Assignments").click
      $wait.until { $driver.find_elements(:link, "Add a new assignment").size > 0 }
      
      # Double check that activity was logged.
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_one + "\"").text).should == "published assignment \"" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_two + "\"").text).should == "published assignment \"" + assignment_two + "\""
      # Check that activity was logged for logged in user.
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_one + "\"").text).should == "published assignment \"" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_two + "\"").text).should == "published assignment \"" + assignment_two + "\""
      
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
