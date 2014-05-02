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
    $driver.quit unless $is_test_suite
  end
  
  it "test_05_students_and_teachers_can_provide_comments_html" do
    begin
      $driver = start_driver({ name: 'Starter League - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      
      $driver.get(@base_url)
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      # ERROR: Caught exception [unknown command []]
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Exercise #" + assignment_two).click
      $driver.find_element(:css, "textarea#comment_content").clear
      $driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on exercise #", assignment_two, "."
      $driver.find_element(:name, "commit").click
      # ERROR: Caught exception [ERROR: Unsupported command [selectWindow | null | ]]
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.comment-content > div.content").text).should == "This is a comment on exercise #" + assignment_two + "."
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:link, "test_document.rtf").click
      $driver.find_element(:css, "textarea#comment_content").clear
      $driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on a resource."
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.comment-content > div.content").text).should == "This is a comment on a resource."
      $driver.find_element(:css, "div.breadcrumbs > a").click
      $driver.find_element(:link, "Discussions").click
      $driver.find_element(:link, "Start a discussion").click
      $driver.find_element(:id, "discussion_subject").clear
      $driver.find_element(:id, "discussion_subject").send_keys "Our first class discussion!"
      $driver.find_element(:css, "textarea#discussion_content").clear
      $driver.find_element(:css, "textarea#discussion_content").send_keys "My first discussion thread"
      $driver.find_element(:id, "subscription_type_none").click
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "strong").text).should == "Outpost Student"
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.content > div.content").text).should == "My first discussion thread"
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").text).should == "started a discussion (Our first class discussion!) in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "posted a comment (This is a comment on a resource.) to test_document.rtf").text).should == "posted a comment (This is a comment on a resource.) to test_document.rtf"
      # Verify
      ($driver.find_element(:link, "posted a comment (This is a comment on exercise #" + assignment_two + ".) to Exercise #" + assignment_two + " - Submission by Outpost").text).should == "posted a comment (This is a comment on exercise #" + assignment_two + ".) to Exercise #" + assignment_two + " - Submission by Outpost"
      $driver.find_element(:link, "Me").click
      # Verify
      ($driver.find_element(:link, "started a discussion (Our first class discussion!) in \"Outpost Test Class\"").text).should == "started a discussion (Our first class discussion!) in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "posted a comment (This is a comment on a resource.) to test_document.rtf").text).should == "posted a comment (This is a comment on a resource.) to test_document.rtf"
      # Verify
      ($driver.find_element(:link, "posted a comment (This is a comment on exercise #" + assignment_two + ".) to Exercise #" + assignment_two + " - Submission by Outpost").text).should == "posted a comment (This is a comment on exercise #" + assignment_two + ".) to Exercise #" + assignment_two + " - Submission by Outpost"
      $driver.find_element(:link, "Logout").click
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:link, "Document #" + document_two + " A written test resource body of cotent.").click
      $driver.find_element(:css, "textarea#comment_content").clear
      $driver.find_element(:css, "textarea#comment_content").send_keys "This is a comment on an document from a teacher!"
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.comment-content > div.content").text).should == "This is a comment on an document from a teacher!"
      # Verify
      ($driver.find_element(:link, "Outpost Teacher").text).should == "Outpost Teacher"
      $driver.find_element(:css, "div.breadcrumbs > a").click
      $driver.find_element(:link, "Discussions").click
      $driver.find_element(:link, "Our first class discussion!").click
      $driver.find_element(:css, "textarea#comment_content").clear
      $driver.find_element(:css, "textarea#comment_content").send_keys "The teacher is commenting on the discussion forum.  ​"
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.comment-content > div.content").text).should == "The teacher is commenting on the discussion forum. ​"
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Assignments").click
      $driver.find_element(:link, "Exercise #" + assignment_two).click
      # Verify
      ($driver.find_element(:css, "div.content").text).should == "Test content for Exercise #" + assignment_two
      $driver.find_element(:link, "Review submissions").click
      $driver.find_element(:css, "span.author-name").click
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      ($driver.find_element(:css, "div.col-xs-11.comment-content > div.content").text).should == "This is a comment on exercise #" + assignment_two + "."
      $driver.find_element(:css, "textarea#comment_content").clear
      $driver.find_element(:css, "textarea#comment_content").send_keys "A teacher's comment on an exercise​"
      $driver.find_element(:name, "commit").click
      # Verify
      ($driver.find_element(:css, "div.assignment-submission-content > div.content").text).should == "This is my first answer to a Lantern exercise. I hope I get it right! " + assignment_two + " Now with a change to it!"
      # Verify
      ($driver.find_element(:xpath, "/html/body/div[2]/div[2]/section/div[2]/div[2]/div").text).should == "A teacher's comment on an exercise​"
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise​) to Exercise #" + assignment_two + " - Submission by Outpost").text).should == "posted a comment (A teacher's comment on an exercise​) to Exercise #" + assignment_two + " - Submission by Outpost"
      # Verify
      ($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      ($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to Document #" + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to Document #" + document_two
      $driver.find_element(:link, "Me").click
      # Verify
      ($driver.find_element(:link, "posted a comment (A teacher's comment on an exercise​) to Exercise #" + assignment_two + " - Submission by Outpost Student").text).should == "posted a comment (A teacher's comment on an exercise​) to Exercise #" + assignment_two + " - Submission by Outpost Student"
      # Verify
      ($driver.find_element(:link, "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!").text).should == "posted a comment (The teacher is commenting on the discussion for...) to Our first class discussion!"
      # Verify
      ($driver.find_element(:link, "posted a comment (This is a comment on an document from a teacher!) to Document #" + document_two).text).should == "posted a comment (This is a comment on an document from a teacher!) to Document #" + document_two
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
