require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Teacher Can Create A New Assignment" do

  before(:all) do
    @test_id = "29"
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @retry_count = 0
    start(@test_id)
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_03_teacher_can_create_a_new_resource" do
    begin
      $driver = start_driver({ name: 'Starter League - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      
      login_as_admin
      
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:css, "#resources .left").find_element(:link, "File").click
      
      sleep(1)
      
      $driver.execute_script("document.getElementById('attachment_file').style.height = 'auto';")
      $driver.execute_script("document.getElementById('attachment_file').style.width = 'auto';")
      $driver.find_element(:id, "attachment_file").send_keys "~/Documents/documents/text-sample1.txt"
      #$driver.find_element(:css, "input.attachment-file-field").clear
      #$driver.find_element(:css, "input.attachment-file-field").send_keys "~/Dropbox/BertCorp/clients/Lantern/test_document.rtf"
      
      document_one = "Resource #" + rand(10000).to_s
      
      $driver.find_element(:css, ".redactor_editor").click
      $driver.find_element(:css, ".redactor_editor").send_keys "An uploaded test resource. " + document_one
      $driver.execute_script("document.getElementsByClassName('redactor_editor')[0].innerHTML = '<p>An uploaded test resource. " + document_one + "</p>'")
      $driver.execute_script("document.getElementById('resource_content').innerHTML = '<p>An uploaded test resource. " + document_one + "</p>'")
      sleep(1)
      
      $driver.find_element(:xpath, "(//button[@name='commit'])[2]").click
      # Verify
      ($driver.find_element(:css, ".title").text).should == "text-sample1.txt"
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "text-sample1.txt (4.03 KB)\nAn uploaded test resource. " + document_one
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:link, "Text document").click
      
      document_two = "Resource #" + rand(10000).to_s
      $driver.find_element(:id, "resource_title").clear
      $driver.find_element(:id, "resource_title").send_keys document_two
      #$driver.find_element(:css, "textarea.resource-content").clear
      #$driver.find_element(:css, "textarea.resource-content").send_keys "A written test resource body of content."
      $driver.find_element(:css, ".redactor_editor").click
      $driver.find_element(:css, ".redactor_editor").send_keys "A written test resource body of content."
      $driver.execute_script("document.getElementsByClassName('redactor_editor')[0].innerHTML = '<p>A written test resource body of content.</p>'")
      $driver.execute_script("document.getElementById('resource_content').innerHTML = '<p>A written test resource body of content.</p>'")
      sleep(1)
      
      $driver.find_element(:xpath, "(//button[@name='commit'])[2]").click
      # Verify
      ($driver.find_element(:css, ".title").text).should == document_two
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "A written test resource body of content."
      $driver.find_element(:link, "Resources").click
      # Verify
      ($driver.find_element(:link, "text-sample1.txt").text).should == "text-sample1.txt"
      # Verify
      ($driver.find_element(:link, document_two + " A written test resource body of content.").text).should == document_two + " A written test resource body of content."
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "added resource \"text-sample1.txt\" in \"Outpost Test Class\"").text).should == "added resource \"text-sample1.txt\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"" + document_two + "\" in \"Outpost Test Class\""
      $driver.find_element(:link, "Me").click
      # Verify
      ($driver.find_element(:link, "added resource \"text-sample1.txt\" in \"Outpost Test Class\"").text).should == "added resource \"text-sample1.txt\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"" + document_two + "\" in \"Outpost Test Class\""
      $driver.find_element(:link, "Logout").click
      
      pass(@test_id)
    rescue => e
      @retry_count = @retry_count + 1
      puts ""
      puts "Exception: #{e.inspect}"
      puts e.backtrace.join("\n")
      puts "Retry: #{@retry_count}"
      puts ""
      #retry if @retry_count < 3
      fail(@test_id, e)
    end
  end
  
end
