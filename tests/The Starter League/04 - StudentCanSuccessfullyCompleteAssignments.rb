require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "04 - Student Can Successfully Complete Assignments" do
  
  before(:all) do
    @test_id = "30"
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
  
  it "Student Can Finish Completion Assignment" do
    begin
      login_as_admin
      
      # First, lets do some prep and get the student's email
      click_link "People"
      $driver.find_element(:id, "students").find_element(:link, "Outpost S.").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      student_email = $driver.find_element(:css, "#profile h4 > small > a").text
      puts "Student: #{student_email}"
      
      # next, lets get the assignments we need
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Assignments"
      
      assignment_one = nil
      assignment_two = nil
      #puts $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').size
      $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').each do |elem| 
        if elem.find_elements(:css, 'td.actions > a').size == 1
          text = elem.find_element(:css, 'td.title > a').text
          klass = elem.find_element(:css, 'td.actions > a:nth-child(1)').attribute('class')
          if klass.include?("no-submissions")
            #puts text
            if (assignment_one == nil) && text.include?("Completion Exercise")
              #puts "COMPLETION!"
              assignment_one = text
              puts "Found Completion Assignment: #{assignment_one}"
            elsif (assignment_two == nil) && text.include?("Submission Exercise")
              #puts "SUBMISSION!"
              assignment_two = text
              puts "Found Submission Assignment: #{assignment_two}"
            end
          end
          break if (assignment_one != nil) && (assignment_two != nil)
        end
      end
      
      ensure_user_logs_out
      
      print "Student can complete first assignment: "
      # Login as student
      $driver.get(@base_url)

      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
            
      # Verify
      ($driver.find_element(:css, "h4").text).should == "Outpost Student (" + student_email + ")"
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Assignments"
      
      # Complete first (completion) exercise
      sleep(1)
      click_link assignment_one
      sleep(1)
      $driver.find_element(:name, "complete").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      # Verify
      puts ($driver.find_element(:css, "span.done.reviewed").text).should == ""

      # Complete second (submission) exercise
      click_link assignment_two
      answer_one = "Answer #" + rand(11111).to_s
      puts "Answer to assignment two: #{answer_one}"
      
      print "Student can complete second assignment: "
      type_redactor_field('assignment_submission_content', "This is my first answer to a Lantern exercise. I hope I get it right! " + answer_one)      
      
      $driver.find_element(:name, "draft").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }

      click_link "← Assignments"
      sleep(1)
      click_link assignment_two
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_two
      
      type_redactor_field('assignment_submission_content', "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!")
      
      $driver.find_element(:name, "complete").click
      close_alert_and_get_its_text(true)
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      click_link assignment_two

      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      puts ($driver.find_element(:css, "div.review-grade > span").text).should == "Your answer is pending review."

      print "Activities created for student: "
      click_link "Outpost Test Class"
      click_link "See all activity..."
      # Verify
      ($driver.find_element(:link, "answered " + assignment_two).text).should == "answered " + assignment_two
      # Verify
      ($driver.find_element(:link, "completed " + assignment_one).text).should == "completed " + assignment_one
      
      click_link "Me"
      # Verify
      ($driver.find_element(:link, "answered " + assignment_two).text).should == "answered " + assignment_two
      # Verify
      puts ($driver.find_element(:link, "completed " + assignment_one).text).should == "completed " + assignment_one

      ensure_user_logs_out
      
      print "Activities created for admin: "
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "See an overview of your students' progress"
      
      $wait.until { $driver.find_elements(:link, "Export to Excel").size > 0 }
      # Verify
      ($driver.find_element(:css, "h5").text).should == "Here's how your students are progressing in Outpost Test Class"
      # Verify
      ($driver.find_element(:link, "Student, Outpost").text).should == "Student, Outpost"
      # Verify
      ($driver.find_element(:css, "td.completed").text).should == "Completed"
      # Verify
      ($driver.find_element(:link, "Pending review").text).should == "Pending review"
      
      pass(@test_id)
    rescue => e
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
