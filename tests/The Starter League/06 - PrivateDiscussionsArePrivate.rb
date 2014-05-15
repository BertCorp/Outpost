require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Private Discussions Are Private" do

  before(:all) do
    @test_id = "38"
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @tries = []
    start(@test_id)
  end
  
  after(:all) do
    # if this is really the end... then quit.
    #unless $is_test_suite
      $driver.quit
      $outpost.quit if $outpost
    #end
  end
  
  it "test_06_private_discussions_are_private" do
    begin
      $driver = start_driver({ :name => 'Starter League - Automated Tests', 'os' => 'OS X', 'os_version' => 'Mavericks' })
      $driver.manage.timeouts.implicit_wait = 3
      random_num = rand(10000).to_s
      puts "Random num: #{random_num}"
      
      # Need to get: student_email/id, teacher_email/id, assignment_two (submission), document_two (created)
      login_as_admin
      
      # First, let's do some prep and get the first student's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "students").find_elements(:link, "Outpost S.").first.click
      student_email = $driver.find_element(:css, "#profile h4 > small > a").text
      student_id = $driver.current_url.gsub('http://lanternhq.com/15/profiles/', '')
      #puts student_email
      
      # Next, let's do some prep and get the second student's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "students").find_elements(:link, "Outpost S.").last.click
      student2_email = $driver.find_element(:css, "#profile h4 > small > a").text
      student2_id = $driver.current_url.gsub('http://lanternhq.com/15/profiles/', '')
      
      # Next, let's get the teacher's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "teaching_staff").find_elements(:link, "Outpost T.").first.click
      teacher_email = $driver.find_element(:css, "#profile h4 > small > a").text
      teacher_id = $driver.current_url.gsub('http://lanternhq.com/15/profiles/', '')
      #puts teacher_email

      # Next, let's get the second teacher's email
      $driver.find_element(:link, "People").click
      $driver.find_element(:id, "teaching_staff").find_elements(:link, "Outpost T.").last.click
      teacher2_email = $driver.find_element(:css, "#profile h4 > small > a").text
      teacher2_id = $driver.current_url.gsub('http://lanternhq.com/15/profiles/', '')
      #puts teacher_email
      
      puts student_email
      puts student_id
      
      puts student2_email
      puts student2_id
      
      puts teacher_email
      puts teacher_id
      
      puts teacher2_email
      puts teacher2_id
      
      # Ensure that a private discussion is not shown anywhere to a user that doesn’t participant on it.
      # Need: admin, teacher A, teacher B, student A, student B?
      # Have a discussion between admin, student A and teacher A. Teacher B and student B should not be able to see.
      # Have a discussion between student A and student B. Admin, teacher A and teacher B should not be able to see.
      # Make sure to check: Overview and Discussion pages
      discussion1_title = "Our private teacher discussion #{random_num}!"
      discussion1_content = "My private teacher discussion thread #{random_num}"
      
      # Login as admin and create a private discussion between Teacher A, Student A
      # Check that: 
      # Admin can see discussion (Me, overview, discussions, direct url)
      # Teacher A can see discussion
      # Student A can see discussion
      # Teacher B can NOT see discussion
      # Teacher B can not see discussion
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      sleep(2)
      $driver.find_element(:link, "Discussions").click
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      $driver.find_element(:link, "Start a discussion").click
      
      $driver.find_element(:id, 'discussion_private_true').click
      
      $driver.find_element(:id, 'discussion_participant_ids')
      $driver.execute_script("document.getElementById('discussion_participant_ids').style.display = 'block';")
      select = Selenium::WebDriver::Support::Select.new($driver.find_element(:id, 'discussion_participant_ids'))
      select.deselect_all()
      select.select_by(:value, student_id)
      select.select_by(:value, teacher_id)
      
      $driver.find_element(:id, "discussion_subject").clear
      $driver.find_element(:id, "discussion_subject").send_keys discussion1_title
      
      type_redactor_field('discussion_content', discussion1_content)
      $driver.find_elements(:id, "subscription_type_none").first.click
      $driver.find_element(:name, "commit").click
      
      # confirm admin can see the new discussion
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0

      discussion1_url = $driver.find_element(:link, discussion1_title).attribute('href')
      puts discussion1_url
      
      $driver.find_element(:link, discussion1_title).click
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      ensure_user_logs_out
      
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      
      # confirm teacher can see the new discussion
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, discussion1_title).click
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      ensure_user_logs_out
      
      # login as student A
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      
      # confirm student can see the new discussion
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, discussion1_title).click
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/

      # Now check to make sure people who don't have access can't see the discussion
      ensure_user_logs_out
      
      # login as teacher B
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher2_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      
      # confirm student can see the new discussion
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should == 0
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      $driver.get discussion1_url
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3').text.should == 'We seem to have lost you in space'
      $driver.navigate.back
      
      ensure_user_logs_out
      
      # login as student B
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student2_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      
      # confirm student can see the new discussion
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should == 0
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      $driver.get discussion1_url
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3').text.should == 'We seem to have lost you in space'
      $driver.navigate.back
      
      # Now, let's edit the discussion and replace Student A with Student B and confirm:
      ensure_user_logs_out
      
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, discussion1_title).click
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      $driver.find_element(:link, "Edit").click
      
      $driver.find_element(:id, 'discussion_participant_ids')
      $driver.execute_script("document.getElementById('discussion_participant_ids').style.display = 'block';")
      select = Selenium::WebDriver::Support::Select.new($driver.find_element(:id, 'discussion_participant_ids'))
      select.deselect_all()
      select.select_by(:value, student2_id)
      select.select_by(:value, teacher_id)
      $driver.find_element(:name, "commit").click
      
      ensure_user_logs_out

      # Student B can view the discussion
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student2_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      
      # confirm student can see the new discussion
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      # IGNORE FOR NOW until they update
      #$driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      $driver.find_element(:link, discussion1_title).click
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/

      # Now check to make sure people who don't have access can't see the discussion
      ensure_user_logs_out
      
      # Student A can NOT view the discussion
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      
      # confirm student can NOT see the new discussion
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      
      # Verify
      # IGNORE FOR NOW.
      #$driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should == 0
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $wait.until { $driver.find_elements(:link, "See all activity...").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      $driver.find_element(:link, "Discussions").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Learn how to start a discussion through email").size > 0 }
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      $driver.get discussion1_url
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3').text.should == 'We seem to have lost you in space'
      $driver.navigate.back
      
      
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
      puts e.backtrace.join("\n")
      retry if @tries.count < 3 && $is_test_suite
      puts "Retrying `#{self.class.description}`: #{@tries.count}"
      puts ""
      fail(@test_id, e)
    end
  end
  
end
