require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "05 - Students and Teachers Can Provide Comments" do

  before(:all) do
    @test_id = "31"
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
  
  it "Students and teachers can comment" do
    begin
      random_num = rand(10000).to_s
      puts "Test identifier: #{random_num}"
      
      # Need to get: student_email, teacher_email, assignment_two (submission), document_two (created)
      login_as_admin
      
      # First, let's do some prep and get the first student's email
      click_link("People")
      $driver.find_element(:id, "students").find_elements(:link, "Outpost S.").first.click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      student_email = $driver.find_element(:css, "#profile h4 > small > a").text
      puts "Student: #{student_email}"
      
      # Next, let's get the teacher's email
      click_link("People")
      $driver.find_element(:id, "teaching_staff").find_elements(:link, "Outpost T.").first.click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      teacher_email = $driver.find_element(:css, "#profile h4 > small > a").text
      puts "Teacher: #{teacher_email}"
      
      # Now, we need the submission assignment
      $driver.find_element(:link, "Classes").click
      click_link("Outpost Test Class")
      #$wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }

      click_link("Assignments")
      #$wait.until { $driver.find_elements(:link, "Reorder").size > 0 }
      
      assignment_two = nil
      #puts $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').size
      $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').each do |elem| 
        if elem.find_elements(:css, 'td.actions > a').size.to_i > 0
          text = elem.find_element(:css, 'td.title > a').text
          klass = elem.find_element(:css, 'td.actions > a:nth-last-child(1)').attribute('class')
          unless klass.include?("no-submissions")
            #puts text
            if text.include?("Submission Exercise")
              #puts "SUBMISSION!"
              assignment_two = text
              break
            end
          end
        end
      end

      # Add a new submission assigment if we don't have one we can use.
      if assignment_two == nil
        print "Can't find existing submission assignment. Attempting to create: "
        click_link "Add a new assignment"
        $driver.find_element(:id, "assignment_requires_submission_true").click

        assignment_two = "Submission Exercise #" + rand(10000).to_s

        $driver.find_element(:id, "assignment_title").clear
        $driver.find_element(:id, "assignment_title").send_keys assignment_two
        $driver.find_element(:name, "commit").click

        type_redactor_field('assignment_task_content', "Test content for " + assignment_two)

        $driver.find_element(:link, "Publish...").click
        $driver.find_element(:name, "publish_and_notify").click
        $wait.until { $driver.find_elements(:link, assignment_two).size > 0 }
        # Verify
        puts ($driver.find_element(:link, assignment_two).text).should == assignment_two
      end
      puts "Submission Assignment: #{assignment_two}"
      
      click_link "Resources"
      click_link "Resources" unless $driver.current_url.include? '/resources'

      # And finally, we need to get the created document
      document_two = $driver.find_element(:css, '.resources-table > tbody > tr.text-resource > td.content > a').text.gsub($driver.find_element(:css, '.resources-table > tbody > tr.text-resource > td.content > a > span').text, '').chomp(" ")
      puts "Document: #{document_two}"
      
      ensure_user_logs_out

      # Login as student
      $driver.get(@base_url)
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Assignments"
      click_link assignment_two
      
      # Complete second (submission) exercise if we haven't already
      if element_present?(:id, 'assignment_submission_content')
        print "Student needs to finish this assignment first: "
        answer_one = "Answer #" + rand(11111).to_s
        
        type_redactor_field('assignment_submission_content', "This is my first answer to a Lantern exercise. I hope I get it right! " + answer_one)      

        $driver.find_element(:name, "draft").click
        click_link "← Assignments"
        click_link assignment_two
        # Verify
        ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_two

        type_redactor_field('assignment_submission_content', "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!")

        $driver.find_element(:name, "complete").click
        close_alert_and_get_its_text(true)
        $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
        
        click_link assignment_two
        puts !element_present?(:id, 'assignment_submission_content')
      end
      
      click_link assignment_two if $driver.find_elements(:link, assignment_two).size > 0
      
      print "Student can comment on assignment: "
      # Student can comment on a submission assignment
      type_redactor_field('comment_content', "This is a student comment on #{assignment_two}. #{random_num}")

      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! #{assignment_two} Now with a change to it!"
      # Verify
      puts ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a student comment on #{assignment_two}. #{random_num}"
      
      # Student can comment on a resource file.
      print "Student can comment on resource file: "
      click_link("Outpost Test Class")
      click_link("Resources")
      sleep(2)
      $driver.find_element(:link, "logger.js").click
      
      type_redactor_field('comment_content', "This is a comment on a resource. #{random_num}")
      
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      # Verify
      puts ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a comment on a resource. #{random_num}"
      
      # Student can create a discussion thread.
      print "Student can create a discussion thread: "
      $driver.find_element(:css, "div.breadcrumbs > a").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      click_link "Discussions"
      sleep(1)
      click_link "Start a discussion"
      
      $driver.find_element(:id, "discussion_subject").clear
      $driver.find_element(:id, "discussion_subject").send_keys "Our class discussion #{random_num}!"
      
      type_redactor_field('discussion_content', "My discussion thread #{random_num}")
      
      $driver.find_elements(:id, "subscription_type_none").last.click
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      # Verify
      ($driver.find_element(:css, "strong").text).should == "Outpost Student"
      # Verify
      puts ($driver.find_element(:css, "div.col-xs-11.content > div.content").text).should == "My discussion thread #{random_num}"
      
      print "Activities created for student: "
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Recent Activity"
      # Verify
      $driver.find_elements(:link, "started a discussion (Our class discussion #{random_num}!) in \"Outpost Test Class\"").size.should > 0
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on a resource. #{random_num}) to logger.js").size.should > 0
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a student comment on #{assignment_two[0..."Submission Exercis".length]}...) to #{assignment_two} - Submission by Outpost").size.should > 0

      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (Our class discussion #{random_num}!) in \"Outpost Test Class\"").size.should > 0
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on a resource. #{random_num}) to logger.js").size.should > 0
      # Verify
      puts $driver.find_elements(:link, "posted a comment (This is a student comment on #{assignment_two[0..."Submission Exercis".length]}...) to #{assignment_two} - Submission by Outpost").size.should > 0

      ensure_user_logs_out

      # Login as teacher and comment on a created resource file.
      print "Teacher can comment on resource file: "
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }

      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Resources"
      sleep(1)
      click_link(document_two + " A written test resource body of content.")
      
      type_redactor_field('comment_content', "This is a comment on an document from a teacher! #{random_num}")
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on an document from a teacher!"
      
      # Very weird hack because clicking the button using selenium goes to homepage.
      current_url = $driver.current_url
      $driver.find_element(:name, "commit").click
      if $driver.current_url != current_url
        $driver.navigate.back
        type_redactor_field('comment_content', "This is a comment on an document from a teacher! #{random_num}")
        $driver.find_element(:name, "commit").click
      end
      sleep(2)      
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(1) > div.comment-content > div.content").text).should == "This is a comment on an document from a teacher! #{random_num}"
      # Verify
      puts ($driver.find_element(:link, "Outpost Teacher").text).should == "Outpost Teacher"
      
      # Teacher can comment on a discussion thread.
      print "Teacher can comment on discussion thread: "
      $driver.find_element(:css, "div.breadcrumbs > a").click
      sleep(1)
      click_link "Discussions"
      sleep(1)
      click_link "Our class discussion #{random_num}!"
      
      type_redactor_field('comment_content', "The teacher is commenting on the discussion forum. #{random_num}")
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "The teacher is commenting on the discussion forum."

      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      # Verify
      puts ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "The teacher is commenting on the discussion forum. #{random_num}"
      
      print "Teacher can comment on assignment: "
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Assignments"
      sleep(1)
      click_link assignment_two
      
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for #{assignment_two}"
      click_link "Review submissions"
      $driver.find_element(:css, "span.author-name").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! #{assignment_two} Now with a change to it!"
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a student comment on #{assignment_two}. #{random_num}"
      
      type_redactor_field('comment_content', "A teacher's comment on an exercise #{random_num}")
      
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      # Verify
      ($driver.find_element(:css, "div.reviewing-assignment-submission > div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! #{assignment_two} Now with a change to it!"
      # Verify
      puts ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "A teacher's comment on an exercise #{random_num}"
      
      print "Activities created for teacher: "
      $driver.find_elements(:css, ".breadcrumb-navigation a").first.click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      click_link "← Assignments"
      click_link "Recent Activity"
      # Verify
      $driver.find_elements(:link, "posted a comment (A teacher's comment on an exercise #{random_num}) to #{assignment_two} - Submission by Outpost").size.should > 0
      #($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost").text).should == "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost"
      # Verify
      $driver.find_elements(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our class discussion #{random_num}!").size.should > 0
      #($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on an document from a teacher...) to #{document_two}").size.should > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to " + document_two

      click_link "Me"
      # Verify
      $driver.find_elements(:link, "posted a comment (A teacher's comment on an exercise #{random_num}) to #{assignment_two} - Submission by Outpost").size.should > 0
      #($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost Student").text).should == "posted a comment (A teacher's comment on an exercise​) to " + assignment_two + " - Submission by Outpost Student"
      # Verify
      $driver.find_elements(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our class discussion #{random_num}!").size.should > 0
      #($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on an document from a teacher...) to #{document_two}").size.should > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to " + document_two
      
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
      elsif e.inspect.include? 'id="flash-msg"'
        # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
        $driver.find_element(:css, '.alert a').click
        sleep(1)
        e.ignore
      end
      # If we get one of the following exceptions, its usually remote server's error.
      if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        # So let's wait a bit and then try again.
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
