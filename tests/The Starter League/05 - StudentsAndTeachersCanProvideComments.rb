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
    @retry_count = 0
    start(@test_id)
  end
  
  after(:all) do
    # if this is really the end... then quit.
    unless $is_test_suite
      $driver.quit
      $outpost.quit
    end
  end
  
  it "test_05_students_and_teachers_can_provide_comments_html" do
    begin
      $driver = start_driver({ name: 'Starter League - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      random_num = rand(10000).to_s
      
      # Need to get: student_email, teacher_email, assignment_two (submission), document_two (created)
      login_as_admin
      
      # First, let's do some prep and get the student's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "students").find_element(:link, "Outpost S.").click
      student_email = $driver.find_element(:css, "#profile h4 > small > a").text
      puts student_email
      
      # Next, let's get the teacher's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "teaching_staff").find_element(:link, "Outpost T.").click
      teacher_email = $driver.find_element(:css, "#profile h4 > small > a").text
      puts teacher_email
      
      # Now, we need the submission assignment
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.current_url.include? '/courses/' }
      sleep(2)
      
      assignment_two = nil
      #puts $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').size
      $driver.find_elements(:css, '.curriculum-items > tbody > tr.assignment').each do |elem| 
        text = elem.find_element(:css, 'td.title > a').text
        klass = elem.find_element(:css, 'td.actions > a').attribute('class')
        unless klass.include?("no-submissions")
          #puts text
          if text.include?("Submission Exercise")
            #puts "SUBMISSION!"
            assignment_two = text
            break
          end
        end
      end
      puts assignment_two
      
      # And finally, we need to get the created document
      document_two = $driver.find_element(:css, '.resources-table > tbody > tr.text-resource > td.content > a').text.gsub($driver.find_element(:css, '.resources-table > tbody > tr.text-resource > td.content > a > span').text, '').chomp(" ")
      puts document_two
      
      #puts $driver.find_elements(:link, "Logout").inspect
      $driver.find_elements(:link, "Logout").first.click
      $driver.find_element(:link, "Logout").click if element_present?(:link, "Logout")
=begin
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
      
      # Student can comment on a submission assignment
      $driver.find_element(:link, assignment_two).click
      
      type_redactor_field('comment_content', 'This is a comment on ' + assignment_two + '.')
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on " + assignment_two + "."
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.comment-content > div.content").text).should == "This is a comment on " + assignment_two + "."
      
      # Student can comment on a resource file.
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:link, "text-sample1.txt").click
      
      type_redactor_field('comment_content', 'This is a comment on a resource.')
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on a resource."
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.comment-content > div.content").text).should == "This is a comment on a resource."
      
      # Student can create a discussion thread.
      $driver.find_element(:css, "div.breadcrumbs > a").click
      $driver.find_element(:link, "Discussions").click
      $driver.find_element(:link, "Start a discussion").click
      $driver.find_element(:id, "discussion_subject").clear
      $driver.find_element(:id, "discussion_subject").send_keys "Our first class discussion!"
      
      type_redactor_field('discussion_content', "My first discussion thread")
      #$driver.find_element(:css, "textarea#discussion_content").clear
      #$driver.find_element(:css, "textarea#discussion_content").send_keys "My first discussion thread"
      $driver.find_elements(:id, "subscription_type_none").last.click
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "strong").text).should == "Outpost Student"
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.content > div.content").text).should == "My first discussion thread"
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      $driver.find_elements(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").size > 0
      #($driver.find_element(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").text).should == "started a discussion (Our first class discussion!) in \"Outpost Test Class\""
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on a resource.) to text-sample1.txt").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on a resource.) to text-sample1.txt").text).should == "posted a comment (This is a comment on a resource.) to test_document.rtf"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on " + assignment_two + ".) to " + assignment_two + " - Submission by Outpost").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on " + assignment_two + ".) to " + assignment_two + " - Submission by Outpost").text).should == "posted a comment (This is a comment on " + assignment_two + ".) to " + assignment_two + " - Submission by Outpost"
      $driver.find_element(:link, "Me").click
      # Verify
      $driver.find_elements(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").size > 0
      #($driver.find_element(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").text).should == "started a discussion (Our first class discussion!) in \"Outpost Test Class\""
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on a resource.) to text-sample1.txt").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on a resource.) to test_document.rtf").text).should == "posted a comment (This is a comment on a resource.) to test_document.rtf"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on exercise #" + assignment_two + ".) to " + assignment_two + " - Submission by Outpost").size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on exercise #" + assignment_two + ".) to " + assignment_two + " - Submission by Outpost").text).should == "posted a comment (This is a comment on exercise #" + assignment_two + ".) to " + assignment_two + " - Submission by Outpost"
      $driver.find_element(:link, "Logout").click
=end      
      # Login as teacher and comment on a created resource file.
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:link, document_two + " A written test resource body of content.").click
      
      type_redactor_field('comment_content', "This is a comment on an document from a teacher!")
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on an document from a teacher!"
      
      # Very weird hack because clicking the button using selenium goes to homepage.
      current_url = $driver.current_url
      $driver.find_element(:name, "commit").click
      if $driver.current_url != current_url
        $driver.navigate.back
        type_redactor_field('comment_content', "This is a comment on an document from a teacher!")
        $driver.find_element(:name, "commit").click
      end
        
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a comment on an document from a teacher!"
      # Verify
      ($driver.find_element(:link, "Outpost Teacher").text).should == "Outpost Teacher"
      
      # Teacher can comment on a discussion thread.
      $driver.find_element(:css, "div.breadcrumbs > a").click
      $driver.find_element(:link, "Discussions").click
      $driver.find_element(:link, "Our first class discussion!").click
      
      type_redactor_field('comment_content', "The teacher is commenting on the discussion forum.")
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "The teacher is commenting on the discussion forum."

      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "The teacher is commenting on the discussion forum."
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Assignments").click
      $driver.find_element(:link, assignment_two).click
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for " + assignment_two
      $driver.find_element(:link, "Review submissions").click
      $driver.find_element(:css, "span.author-name").click
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "This is a comment on " + assignment_two + "."
      
      type_redactor_field('comment_content', "A teacher's comment on an exercise")
      
      #$driver.find_element(:css, "textarea#comment_content").clear
      #$driver.find_element(:css, "textarea#comment_content").send_keys "A teacher's comment on an exercise"
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.reviewing-assignment-submission > div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      ($driver.find_element(:css, ".comments > .comment:nth-last-child(2) > div.comment-content > div.content").text).should == "A teacher's comment on an exercise"
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      $driver.find_elements(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost").size > 0
      #($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost").text).should == "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost"
      # Verify
      $driver.find_elements(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").size > 0
      #($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to " + document_two
      $driver.find_element(:link, "Me").click
      # Verify
      $driver.find_elements(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost Student").size > 0
      #($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise) to " + assignment_two + " - Submission by Outpost Student").text).should == "posted a comment (A teacher's comment on an exercise​) to " + assignment_two + " - Submission by Outpost Student"
      # Verify
      $driver.find_elements(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").size > 0
      #($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      $driver.find_elements(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).size > 0
      #($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to " + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to " + document_two
      $driver.find_element(:link, "Logout").click
      
      pass(@test_id)
    rescue => e
      @retry_count = @retry_count + 1
      puts ""
      puts "Current Page: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      puts "Retry: #{@retry_count}"
      puts ""
      retry if @retry_count < 3 && $is_test_suite
      fail(@test_id, e)
    end
  end
  
end
