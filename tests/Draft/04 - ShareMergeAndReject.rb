require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "04 - Share, Merge and Reject" do

  before(:all) do
    @test_id = "10"
    puts "** Starting: #{self.class.description} (Test ##{@test_id}) **"
    # Prep with variables we need
    @random_num = rand(1000)
    print "Set test identifier: #{@random_num}"
    @share_link = ''
  end

  before(:each) do |x|
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @tries = []
    $driver = start_driver()
    start(@test_id)
    puts ""
    print "#{x.example.description}"
  end
  
  after(:all) do
    # if this is really the end... then quit.
    puts ""
    puts "** Finished: #{self.class.description} **"
    #unless $is_test_suite
      $driver.quit
    #end
  end
  
  it "Create File to Share" do
    begin
      # Make sure we start on main homepage...
      $driver.get(@base_url + 'documents')
      # But we don't know which user we are logged in as, so let's just make sure we are logged out.
      if $driver.find_elements(:link_text, "LOGOUT").size.to_i > 0 
        ensure_user_logs_out
        
        $driver.find_element(:link, "LOGIN").click
        sleep(1)
      end
      # now make sure we login as main user
      start_logged_in
      
      # just create a new document for this
      $driver.find_element(:id, "new_document_button").click
      $driver.find_element(:id, "document_content").send_keys "Creating a new document that we will share. #{@random_num}"
      
      save_document
      puts ": ."
      
      go_home_from_document

      $driver.find_element(:css, ".document:nth-child(1)").find_element(:link, "SHARE").click

      while @share_link == ''
        begin
          $wait.until { $driver.find_elements(:id, 'share_url').size > 0 }
        rescue
          $driver.get(@base_url + 'documents')
          sleep(1)
          $driver.find_element(:css, ".document:nth-child(1)").find_element(:link, "SHARE").click
        end
        if $driver.find_elements(:id, 'share_url').size > 0
          @share_link = $driver.find_element(:id, "share_url").text
        end
      end
      puts "Share link: #{@share_link}"
      
      $driver.find_element(:css, '#invite_link > div > a').click

      ensure_user_logs_out
      
      print "Accept and Merge Edits: "
      
      $driver.get(@share_link)
      #sidebar_content > div > div:nth-child(2) > a
      $driver.find_element(:css, "#sidebar_content div.instruction_copy a").click
      sleep(1)
      $driver.find_element(:link_text, "LOGIN").click
      sleep(1)
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft_editor@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").send_keys "testcase12"
      $driver.find_element(:name, "commit").click      
      $wait.until { $driver.find_elements(:id, 'document_content').size > 0 }
      
      if $driver.find_elements(:css, '#done_editing_button').size < 1
        puts "Current location before share link: #{$driver.current_url}"
        puts "Go to share link: #{@share_link}"
        $driver.get(@share_link)
        sleep(1)
        $driver.find_element(:css, "#sidebar_content div.instruction_copy a").click
        sleep(1)
      end
      
      $driver.find_element(:id, "document_content").clear
      $driver.find_element(:id, "document_content").send_keys "I edited the document that i created in the draft composer. I am a friend editing this document. #{@random_num}"
      
      save_document
      
      sleep(2)
      
      if !$driver.find_element(:css, "#done_editing_button").displayed?
        $driver.execute_script("document.getElementById('done_editing_button').style.display = 'block'")
      end
      $driver.find_element(:css, "#done_editing_button").click
      
      $wait.until { $driver.find_elements(:id, "note").size > 0 }
      $driver.find_element(:id, "note").clear
      $driver.find_element(:id, "note").send_keys "I edited this document."
      $driver.find_element(:css, "form > input[name=\"commit\"]").click
      
      ensure_user_logs_out

      $driver.find_element(:link, "LOGIN").click
      $driver.find_element(:id, "draft_user_email").clear
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").clear
      $driver.find_element(:id, "draft_user_password").send_keys "changeme"
      $driver.find_element(:name, "commit").click

      $driver.find_element(:css, ".document:nth-child(1) .commands a").click
      sleep(1)
      $driver.find_element(:link, "ACCEPT CHANGE").click
      sleep(2)

      $driver.find_element(:id, "home_button_drafts").click
      $driver.find_element(:css, ".document:nth-child(1) .row-fluid .span9 a.btn").click
      sleep(1)
      puts ($driver.find_element(:css, "#document_container > div > p").text).should == "I edited the document that i created in the draft composer. I am a friend editing this document. #{@random_num}"
      
      $driver.find_element(:css, 'i.icon-home').click
    
      print "Reject and Ignore Changes: "
      
      ensure_user_logs_out
      
      $driver.find_element(:link, "LOGIN").click
      $driver.find_element(:id, "draft_user_email").clear
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft_editor@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").clear
      $driver.find_element(:id, "draft_user_password").send_keys "testcase12"
      $driver.find_element(:name, "commit").click
      sleep(1)
      
      $driver.find_element(:link, "EDIT").click
      $driver.find_element(:id, "document_content").clear
      $driver.find_element(:id, "document_content").send_keys "I edited the document that i created in the draft composer. I am a friend editing this document. #{@random_num} Here is another change to this document."

      save_document
      
      sleep(2)
      
      if !$driver.find_element(:css, "#done_editing_button").displayed?
        $driver.execute_script("document.getElementById('done_editing_button').style.display = 'block'")
      end
      $driver.find_element(:css, "#done_editing_button").click
      
      $wait.until { $driver.find_elements(:id, "note").size > 0 }
      $driver.find_element(:id, "note").clear
      $driver.find_element(:id, "note").send_keys "I edited this document."
      $driver.find_element(:css, "form > input[name=\"commit\"]").click
      
      close_alert_and_get_its_text(true) if alert_present?
      
      sleep(1)
      $driver.find_element(:link, "VIEW").click
      sleep(1)
      # Verify
      ($driver.find_element(:css, "#document_container > div > p").text).should == "I edited the document that i created in the draft composer. I am a friend editing this document. #{@random_num} Here is another change to this document."
      
      $driver.find_element(:css, 'i.icon-home').click

      ensure_user_logs_out
      
      $driver.find_element(:link, "LOGIN").click
      $driver.find_element(:id, "draft_user_email").clear
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").clear
      $driver.find_element(:id, "draft_user_password").send_keys "changeme"
      $driver.find_element(:name, "commit").click
      #$driver.find_element(:link, "1 COLLABORATOR").click
      $driver.find_element(:css, ".document:nth-child(1) .commands a").click
      $driver.find_element(:link, "IGNORE").click
      $driver.find_element(:css, "i.icon-home").click
      sleep(1)
      $driver.find_element(:link, "VIEW").click
      sleep(1)
      ($driver.find_element(:css, "#document_container > div > p").text).should == "I edited the document that i created in the draft composer. I am a friend editing this document. #{@random_num}"
      
      $driver.find_element(:css, 'i.icon-home').click
      
      ensure_user_logs_out
      
      pass(@test_id)
    rescue => e
      if e.inspect.include?("Selenium::WebDriver::Error::UnknownError") || e.inspect.include?("has already finished")
        $driver = nil
        $driver = start_driver()
        e.ignore
      elsif e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      elsif e.inspect.include? 'id="IModalOverlay"'
        # For Draft, we have this pesky Intercom modal that causes issues. If we ever run into it, ignore it and just carry on.
        $driver.navigate.refresh
        sleep(3)
        e.ignore
      elsif ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        # If we get one of the following exceptions, its usually remote server's error, so let's wait a bit and then try again.
        puts ""
        puts "Retry due to remote server exception: #{e.inspect}"
        sleep(10)
        retry
      end
      # otherwise, let's try again
      @tries << { exception: e.inspect, backtrace: e.backtrace }      
      close_alert_and_get_its_text(true) if alert_present?
      puts ""
      puts "Current url: #{$driver.current_url}"
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      if @tries.count < 3 && $is_test_suite
        puts "Retrying `#{self.class.description}`: #{@tries.count}"
        retry 
      end
      puts ""
      fail(@test_id, e)
    end
  end
  
end
