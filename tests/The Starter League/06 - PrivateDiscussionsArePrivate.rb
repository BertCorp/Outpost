require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "06 - Private Discussions Are Private" do
  
  before(:all) do
    @test_id = "38"
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
    #unless $is_test_suite
      $driver.quit
    #end
  end
  
  it "Private Discussions Are Private" do
    begin
      random_num = rand(10000).to_s
      puts "Test identifier: #{random_num}"
      
      # Need to get: student_email/id, teacher_email/id, assignment_two (submission), document_two (created)
      login_as_admin
      
      # First, let's do some prep and get the first student's email
      print "Student A: "
      click_link "People"
      $driver.find_element(:id, "students").find_elements(:link, "Outpost S.").first.click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }

      student_email = $driver.find_element(:css, "#profile h4 > small > a").text
      student_id = $driver.current_url.split('/').last
      puts "#{student_email} // #{student_id}"
      
      # Next, let's do some prep and get the second student's email
      print "Student B: "
      click_link "People"
      $driver.find_element(:id, "students").find_elements(:link, "Outpost S.").last.click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      student2_email = $driver.find_element(:css, "#profile h4 > small > a").text
      student2_id = $driver.current_url.split('/').last
      puts "#{student2_email} // #{student2_id}"
      
      # Next, let's get the teacher's email
      print "Teacher A: "
      click_link "People"
      $driver.find_element(:id, "teaching_staff").find_elements(:link, "Outpost T.").first.click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      teacher_email = $driver.find_element(:css, "#profile h4 > small > a").text
      teacher_id = $driver.current_url.split('/').last
      puts "#{teacher_email} // #{teacher_id}"

      # Next, let's get the second teacher's email
      print "Teacher B: "
      click_link "People"
      $driver.find_element(:id, "teaching_staff").find_elements(:link, "Outpost T.").last.click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }

      teacher2_email = $driver.find_element(:css, "#profile h4 > small > a").text
      teacher2_id = $driver.current_url.split('/').last
      puts "#{teacher2_email} // #{teacher2_id}"
            
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
      print "Admin can create discussion with Student A, Teacher A: "
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      click_link "Discussions"
      sleep(1)
      click_link "Start a discussion"
      
      $driver.find_element(:id, 'discussion_private_true').click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
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
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      puts $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      discussion1_url = $driver.current_url
      puts "Discussion url: #{discussion1_url}"
      
      # confirm admin can see the new discussion
      print "Admin can see discussion: "
      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0

      #discussion1_url = $driver.find_element(:link, discussion1_title).attribute('href')
      
      click_link discussion1_title
      # Verify
      puts $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      ensure_user_logs_out
      
      # confirm teacher can see the new discussion
      print "Teacher A can see discussion: "
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      sleep(1)
      click_link discussion1_title
      # Verify
      puts $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      ensure_user_logs_out
      
      # confirm student can see the new discussion
      print "Student A can see discussion: "
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      sleep(1)
      click_link discussion1_title
      # Verify
      puts $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/

      # Now check to make sure people who don't have access can't see the discussion
      ensure_user_logs_out
      
      # confirm teacher B can NOT see the new discussion
      print "Teacher B can NOT see discussion: "
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys teacher2_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should == 0
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      sleep(1)
      $driver.get discussion1_url
      sleep(1)
      # Verify
      puts $driver.find_element(:css, 'h3').text.should == 'We seem to have lost you in space'
      $driver.navigate.back
      
      ensure_user_logs_out
      
      # confirm student B can NOT see the new discussion
      print "Student B can NOT see discussion: "
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student2_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should == 0
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      sleep(1)
      $driver.get discussion1_url
      sleep(1)
      # Verify
      puts $driver.find_element(:css, 'h3').text.should == 'We seem to have lost you in space'
      $driver.navigate.back
      
      # Now, let's edit the discussion and replace Student A with Student B and confirm:
      ensure_user_logs_out
      
      login_as_admin
      print "Admin can edit discussion to include Student B not Student A: "
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      sleep(1)
      click_link discussion1_title
      # Verify
      $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      click_link "Edit"
      $driver.find_element(:id, 'discussion_participant_ids')
      $driver.execute_script("document.getElementById('discussion_participant_ids').style.display = 'block';")
      select = Selenium::WebDriver::Support::Select.new($driver.find_element(:id, 'discussion_participant_ids'))
      select.deselect_all()
      select.select_by(:value, student2_id)
      select.select_by(:value, teacher_id)
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      puts $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/
      
      ensure_user_logs_out

      # confirm student B can see the new discussion
      print "Student B can see discussion: "
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student2_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should > 0
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should > 0
      
      sleep(1)
      click_link discussion1_title
      # Verify
      puts $driver.find_element(:css, 'h3.subject').text.should =~ /^#{discussion1_title}/

      # Now check to make sure people who don't have access can't see the discussion
      ensure_user_logs_out
      
      # confirm student A can NOT see the new discussion
      print "Student A can NOT see discussion: "
      click_link "Log in"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys student_email
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "test12"
      $driver.find_element(:name, "commit").click
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
      
      click_link "Me"
      # Verify
      $driver.find_elements(:link, "started a discussion (#{discussion1_title}) in \"Outpost Test Class\"").size.should == 0
      
      $driver.find_element(:link, "Classes").click
      click_link "Outpost Test Class"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      click_link "Discussions"
      # Verify
      $driver.find_elements(:link, discussion1_title).size.should == 0
      
      sleep(1)
      $driver.get discussion1_url
      sleep(1)
      # Verify
      $driver.find_element(:css, 'h3').text.should == 'We seem to have lost you in space'
      
      pass(@test_id)
    rescue => e
      # Ignore any modal windows that popped up that might be causing us an issue.
      if e.inspect.include? 'UnhandledAlertError'
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
