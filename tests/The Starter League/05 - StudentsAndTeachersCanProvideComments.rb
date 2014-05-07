require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Students and Teachers Can Provide Comments" do

  before(:all) do
    @test_id = "31"
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
  
  it "test_05_students_and_teachers_can_provide_comments_html" do
    begin
      $driver = start_driver({ :name => 'Starter League - Automated Tests', 'os' => 'OS X', 'os_version' => 'Mavericks' })
      $driver.manage.timeouts.implicit_wait = 3
      random_num = rand(10000).to_s
      
      # Need to get: student_email, teacher_email, assignment_two (submission), document_two (created)
      login_as_admin
      
      # First, let's do some prep and get the student's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "students").find_element(:link, "Outpost S.").click
      student_email = $driver.find_element(:css, "#profile h4 > small > a").text
      #puts student_email
      
      # Next, let's get the teacher's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "teaching_staff").find_element(:link, "Outpost T.").click
      teacher_email = $driver.find_element(:css, "#profile h4 > small > a").text
      #puts teacher_email
      
      # Now, we need the submission assignment
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      
      $driver.find_element(:link, "Assignments").click
      $wait.until { $driver.find_elements(:link, "Reorder").size > 0 }
      
      assignment_two = nil
      #puts $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').size
      $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').each do |elem| 
        if elem.find_elements(:css, 'td.actions > a').size == 1
          text = elem.find_element(:css, 'td.title > a').text
          klass = elem.find_element(:css, 'td.actions > a:nth-child(1)').attribute('class')
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
      #puts assignment_one
      #puts assignment_two

      # Add a new submission assigment if we don't have one we can use.
      if assignment_two == nil
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
        #puts "Added new assignment: #{assignment_two}"
      end
      
      $driver.find_element(:link, "Resources").click
      $wait.until { $driver.find_elements(:link, "Text document").size > 0 }
      
      # And finally, we need to get the created document
      document_two = $driver.find_element(:css, '.resources-table > tbody > tr.text-resource > td.content > a').text.gsub($driver.find_element(:css, '.resources-table > tbody > tr.text-resource > td.content > a > span').text, '').chomp(" ")
      #puts document_two
      
      #puts $driver.find_elements(:link, "Logout").inspect
      $driver.find_element(:css, '.alert a').click if element_present?(:id, 'flash-msg')
      $driver.find_elements(:link, "Logout").first.click
      $driver.find_element(:link, "Logout").click if element_present?(:link, "Logout")

      # Login as student
      $driver.get(@base_url)
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click

      $driver.find_element(:link, "Assignments").click
      $wait.until { $driver.find_elements(:link, assignment_two).size > 0 }

      $driver.find_element(:link, assignment_two).click
            
      # Complete second (submission) exercise if we haven't already
      if element_present?(:id, 'assignment_submission_content')
        answer_one = "Answer #" + rand(11111).to_s
        
        type_redactor_field('assignment_submission_content', "This is my first answer to a Lantern exercise. I hope I get it right! " + answer_one)      

        $driver.find_element(:name, "draft").click
        $driver.find_element(:link, "← Assignments").click
        $wait.until { $driver.find_elements(:link, assignment_two).size > 0 }
        $driver.find_element(:link, assignment_two).click
        # Verify
        ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_two

        type_redactor_field('assignment_submission_content', "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!")

        $driver.find_element(:name, "complete").click
        if alert_present?
          close_alert_and_get_its_text(true)
        end
        sleep(2)
        $driver.find_element(:link, assignment_two).click
      end
      
      # Student can comment on a submission assignment
      type_redactor_field('comment_content', "This is a comment on #{assignment_two}. #{random_num}")
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on " + assignment_two + "."
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! #{assignment_two} Now with a change to it!"
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a comment on #{assignment_two}. #{random_num}"
      
      # Student can comment on a resource file.
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click

      $wait.until { $driver.find_elements(:link, "text-sample1.txt").size > 0 }
      $driver.find_element(:link, "text-sample1.txt").click
      
      type_redactor_field('comment_content', "This is a comment on a resource. #{random_num}")
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on a resource."
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a comment on a resource. #{random_num}"
      
      # Student can create a discussion thread.
      $driver.find_element(:css, "div.breadcrumbs > a").click
      $wait.until { $driver.find_elements(:link, "Discussions").size > 0 }
      $driver.find_element(:link, "Discussions").click
      $wait.until { $driver.find_elements(:link, "Start a discussion").size > 0 }
      $driver.find_element(:link, "Start a discussion").click
      $driver.find_element(:id, "discussion_subject").clear
      $driver.find_element(:id, "discussion_subject").send_keys "Our class discussion #{random_num}!"
      
      type_redactor_field('discussion_content', "My discussion thread #{random_num}")
      #$driver.find_element(:css, "textarea#discussion_content").clear
      #$driver.find_element(:css, "textarea#discussion_content").send_keys "My first discussion thread"
      $driver.find_elements(:id, "subscription_type_none").last.click
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "strong").text).should == "Outpost Student"
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.content > div.content").text).should == "My discussion thread #{random_num}"
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "Recent Activity").size > 0 }
      $driver.find_element(:link, "Recent Activity").click
      sleep(2)
      # Verify
      $driver.find_elements(:link, "started a discussion (Our class discussion #{random_num}!) in \"Outpost Test Class\"").size > 0
      #($driver.find_element(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").text).should == "started a discussion (Our first class discussion!) in \"Outpost Test Class\""
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on a resource. #{random_num}) to text-sample1.txt").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on a resource.) to text-sample1.txt").text).should == "posted a comment (This is a comment on a resource.) to test_document.rtf"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on #{assignment_two}. #{random_num}) to #{assignment_two} - Submission by Outpost").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on " + assignment_two + ".) to " + assignment_two + " - Submission by Outpost").text).should == "posted a comment (This is a comment on " + assignment_two + ".) to " + assignment_two + " - Submission by Outpost"
      $driver.find_element(:link, "Me").click
      sleep(2)
      # Verify
      $driver.find_elements(:link, "started a discussion (Our first class discussion! #{random_num}) in \"Outpost Test Class\"").size > 0
      #($driver.find_element(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").text).should == "started a discussion (Our first class discussion!) in \"Outpost Test Class\""
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on a resource. #{random_num}) to text-sample1.txt").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on a resource.) to test_document.rtf").text).should == "posted a comment (This is a comment on a resource.) to test_document.rtf"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on #{assignment_two}. #{random_num}) to #{assignment_two} - Submission by Outpost").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on exercise #" + assignment_two + ".) to " + assignment_two + " - Submission by Outpost").text).should == "posted a comment (This is a comment on exercise #" + assignment_two + ".) to " + assignment_two + " - Submission by Outpost"
      $driver.find_element(:link, "Logout").click
      $wait.until { $driver.find_elements(:link, "Learn more").size > 0 }

      # Login as teacher and comment on a created resource file.
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "Resources").size > 0 }
      $driver.find_element(:link, "Resources").click
      $wait.until { $driver.find_elements(:link, document_two + " A written test resource body of content.").size > 0 }
      $driver.find_element(:link, document_two + " A written test resource body of content.").click
      
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
        
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a comment on an document from a teacher! #{random_num}"
      # Verify
      ($driver.find_element(:link, "Outpost Teacher").text).should == "Outpost Teacher"
      
      # Teacher can comment on a discussion thread.
      $driver.find_element(:css, "div.breadcrumbs > a").click
      $driver.find_element(:link, "Discussions").click
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      $driver.find_element(:link, "Our class discussion #{random_num}!").click
      
      type_redactor_field('comment_content', "The teacher is commenting on the discussion forum. #{random_num}")
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "The teacher is commenting on the discussion forum."

      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "The teacher is commenting on the discussion forum. #{random_num}"
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "Assignments").size > 0 }
      $driver.find_element(:link, "Assignments").click
      $wait.until { $driver.find_elements(:link, assignment_two).size > 0 }
      $driver.find_element(:link, assignment_two).click
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for #{assignment_two}"
      $driver.find_element(:link, "Review submissions").click
      $driver.find_element(:css, "span.author-name").click
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! #{assignment_two} Now with a change to it!"
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a comment on #{assignment_two}. #{random_num}"
      
      type_redactor_field('comment_content', "A teacher's comment on an exercise #{random_num}")
      
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "A teacher's comment on an exercise"
      $driver.find_element(:name, "commit").click
      sleep(2)
      # Verify
      ($driver.find_element(:css, "div.reviewing-assignment-submission > div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! #{assignment_two} Now with a change to it!"
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "A teacher's comment on an exercise #{random_num}"
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "Recent Activity").size > 0 }
      $driver.find_element(:link, "Recent Activity").click
      sleep(2)
      # Verify
      $driver.find_elements(:link, "posted a comment (A teacher's comment on an exercise #{random_num}) to #{assignment_two} - Submission by Outpost").size > 0
      #($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost").text).should == "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost"
      # Verify
      $driver.find_elements(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our class discussion #{random_num}!").size > 0
      #($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on an document from a teacher! #{random_num}) to #{document_two}").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to " + document_two
      $driver.find_element(:link, "Me").click
      sleep(2)
      # Verify
      $driver.find_elements(:link, "posted a comment (A teacher's comment on an exercise #{random_num}) to #{assignment_two} - Submission by Outpost Student").size > 0
      #($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost Student").text).should == "posted a comment (A teacher's comment on an exercise​) to " + assignment_two + " - Submission by Outpost Student"
      # Verify
      $driver.find_elements(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our class discussion #{random_num}!").size > 0
      #($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on an document from a teacher! #{random_num}) to #{document_two}").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to " + document_two
      $driver.find_element(:link, "Logout").click
      #$wait.until { $driver.find_elements(:link, "Learn more").size > 0 }
      
      pass(@test_id)
    rescue => e
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
      puts e.backtrace.join("\n") unless $is_test_suite
      puts "Retrying `#{self.class.description}`: #{@tries.count}"
      puts ""
      retry if @tries.count < 3 && $is_test_suite
      fail(@test_id, e)
    end
  end
  
end
