require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "02 - Teacher Can Add Assignments" do
  
  before(:all) do
    @test_id = "28"
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
  
  it "Teacher Can Create Assignments" do
    begin
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      
      # Add a new completion assignment
      click_link "Add a new assignment"
      
      assignment_one = "Completion Exercise #" + rand(10000).to_s
      print "Create assignment (#{assignment_one}): "
      
      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys assignment_one
      $driver.find_element(:name, "commit").click
      
      type_redactor_field('assignment_task_content', "Test content for " + assignment_one)
      
      click_link "Publish..."
      $driver.find_element(:name, "publish_and_notify").click
      sleep(1)
      # Vertify
      ($driver.find_elements(:css, ".alert-danger").size).should == 0
      # Verify
      ($driver.find_element(:link, assignment_one).text).should == assignment_one
      click_link assignment_one
      
      $wait.until { $driver.find_elements(:link, "← Assignments").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == assignment_one + "\n- change this"
      # Verify
      puts ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_one
      click_link "← Assignments"
      
      # Add a new submission assigment
      click_link "Add a new assignment"
      $driver.find_element(:id, "assignment_requires_submission_true").click

      assignment_two = "Submission Exercise #" + rand(10000).to_s
      print "Create assignment (#{assignment_two}): "

      $driver.find_element(:id, "assignment_title").clear
      $driver.find_element(:id, "assignment_title").send_keys assignment_two
      $driver.find_element(:name, "commit").click

      type_redactor_field('assignment_task_content', "Test content for " + assignment_two)

      click_link "Publish..."
      $driver.find_element(:name, "publish_and_notify").click
      # Verify
      ($driver.find_element(:link, assignment_two).text).should == assignment_two
      click_link assignment_two

      $wait.until { $driver.find_elements(:link, "← Assignments").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == assignment_two + "\nrequires a submission (private) - change this"
      # Verify
      puts ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_two
      click_link "← Assignments"
      
      # Double check that activity was logged.
      print "Activities created for admin: "
      click_link "Recent Activity"
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_one + "\"").text).should == "published assignment \"" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_two + "\"").text).should == "published assignment \"" + assignment_two + "\""
      # Check that activity was logged for logged in user.
      click_link "Me"
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_one + "\"").text).should == "published assignment \"" + assignment_one + "\""
      # Verify
      ($driver.find_element(:link, "published assignment \"" + assignment_two + "\"").text).should == "published assignment \"" + assignment_two + "\""
      
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
