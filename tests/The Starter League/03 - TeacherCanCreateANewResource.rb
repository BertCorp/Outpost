require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Teacher Can Add Resources" do
  
  before(:all) do
    @test_id = "29"
    print "** Starting: #{self.class.description} (Test ##{@test_id}) **"
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
    unless $is_test_suite
      $driver.quit
    end
  end
  
  it "Teacher Can Upload Resource" do
    begin
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:css, "#resources .left").find_element(:link, "File").click
      
      sleep(1)
      
      $driver.execute_script("document.getElementById('attachment_file').style.height = 'auto';")
      $driver.execute_script("document.getElementById('attachment_file').style.width = 'auto';")
      begin
        $driver.find_element(:id, "attachment_file").send_keys "~/Documents/documents/text-sample1.txt"
      rescue
        $driver.find_element(:id, "attachment_file").send_keys "/Users/test1/Documents/documents/text-sample1.txt"        
      end
      #$driver.find_element(:css, "input.attachment-file-field").clear
      #$driver.find_element(:css, "input.attachment-file-field").send_keys "~/Dropbox/BertCorp/clients/Lantern/test_document.rtf"
      
      document_one = "Resource #" + rand(10000).to_s
      print " (#{document_one}): "
      type_redactor_field('resource_content', "An uploaded test resource. " + document_one)
      
      $driver.find_element(:xpath, "(//button[@name='commit'])[2]").click
      # Verify
      ($driver.find_element(:css, ".title").text).should == "text-sample1.txt"
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "text-sample1.txt (4.03 KB)\nAn uploaded test resource. " + document_one
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
      if @tries.count < 3 && $is_test_suite
        puts "Retrying `#{self.class.description}`: #{@tries.count}"
        puts ""
        retry
      end
      fail(@test_id, e)
    end
  end
    
  it "Teacher Can Create Resource" do
    begin
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Add a text document").size > 0 }
      $driver.find_element(:link, "Resources").click
      $wait.until { $driver.find_elements(:link, "Text document").size > 0 }
      $driver.find_element(:link, "Text document").click
      
      document_two = "Resource #" + rand(10000).to_s
      print " (#{document_two}): "
      
      $driver.find_element(:id, "resource_title").clear
      $driver.find_element(:id, "resource_title").send_keys document_two
      #$driver.find_element(:css, "textarea.resource-content").clear
      #$driver.find_element(:css, "textarea.resource-content").send_keys "A written test resource body of content."
      type_redactor_field('resource_content', "A written test resource body of content.")      
      
      $driver.find_element(:xpath, "(//button[@name='commit'])[2]").click
      # Verify
      ($driver.find_element(:css, ".title").text).should == document_two
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "A written test resource body of content."
      $driver.find_element(:link, "Resources").click
      sleep(2)
      # Verify
      ($driver.find_element(:link, "text-sample1.txt").text).should == "text-sample1.txt"
      # Verify
      ($driver.find_element(:link, document_two + " A written test resource body of content.").text).should == document_two + " A written test resource body of content."
      $driver.find_element(:link, "Recent Activity").click
      sleep(2)
      # Verify
      ($driver.find_element(:link, "added resource \"text-sample1.txt\" in \"Outpost Test Class\"").text).should == "added resource \"text-sample1.txt\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"" + document_two + "\" in \"Outpost Test Class\""
      $driver.find_element(:link, "Me").click
      sleep(2)
      $wait.until { $driver.find_elements(:link, "Update your personal info").size > 0 }
      # Verify
      ($driver.find_element(:link, "added resource \"text-sample1.txt\" in \"Outpost Test Class\"").text).should == "added resource \"text-sample1.txt\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"" + document_two + "\" in \"Outpost Test Class\""

      ensure_user_logs_out
      
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
      if @tries.count < 3 && $is_test_suite
        puts "Retrying `#{self.class.description}`: #{@tries.count}"
        puts ""
        retry
      end
      fail(@test_id, e)
    end
  end
  
end
