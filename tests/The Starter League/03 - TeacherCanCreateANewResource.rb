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
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_03_teacher_can_create_a_new_resource" do
    begin
      start_time = Time.now
      
      start(@test_id)
      $driver = start_driver({ name: 'Starter League - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      
      $driver.get(@base_url)
      $driver.find_element(:link, "Log in").click
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:link, "File").click
      $driver.find_element(:css, "input.attachment-file-field").clear
      $driver.find_element(:css, "input.attachment-file-field").send_keys "~/Dropbox/BertCorp/clients/Lantern/test_document.rtf"
      # ERROR: Caught exception [ERROR: Unsupported command [getEval |  | ]]
      $driver.find_element(:css, "textarea.resource-content").clear
      $driver.find_element(:css, "textarea.resource-content").send_keys "An uploaded test resource. #", document_one
      $driver.find_element(:xpath, "(//button[@name='commit'])[2]").click
      # Verify
      ($driver.find_element(:css, ".title").text).should == "test_document.rtf"
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "test_document.rtf (318 Bytes) \n \n An uploaded test resource. #" + document_one
      $driver.find_element(:link, "Classes").click
      $driver.find_element(:link, "Outpost Test Class").click
      $driver.find_element(:link, "Resources").click
      $driver.find_element(:link, "Text document").click
      # ERROR: Caught exception [ERROR: Unsupported command [getEval |  | ]]
      $driver.find_element(:id, "resource_title").clear
      $driver.find_element(:id, "resource_title").send_keys "Document #", document_two
      $driver.find_element(:css, "textarea.resource-content").clear
      $driver.find_element(:css, "textarea.resource-content").send_keys "A written test resource body of cotent."
      $driver.find_element(:xpath, "(//button[@name='commit'])[2]").click
      # Verify
      ($driver.find_element(:css, ".title").text).should == "Document #" + document_two
      # Verify
      ($driver.find_element(:css, "div.post-content").text).should == "A written test resource body of cotent."
      $driver.find_element(:link, "Resources").click
      # Verify
      ($driver.find_element(:link, "test_document.rtf").text).should == "test_document.rtf"
      # Verify
      ($driver.find_element(:link, "Document #" + document_two + " A written test resource body of cotent.").text).should == "Document #" + document_two + " A written test resource body of cotent."
      $driver.find_element(:link, "Recent Activity").click
      # Verify
      ($driver.find_element(:link, "added resource \"test_document.rtf\" in \"Outpost Test Class\"").text).should == "added resource \"test_document.rtf\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"Document #" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"Document #" + document_two + "\" in \"Outpost Test Class\""
      $driver.find_element(:link, "Me").click
      # Verify
      ($driver.find_element(:link, "added resource \"test_document.rtf\" in \"Outpost Test Class\"").text).should == "added resource \"test_document.rtf\" in \"Outpost Test Class\""
      # Verify
      ($driver.find_element(:link, "added resource \"Document #" + document_two + "\" in \"Outpost Test Class\"").text).should == "added resource \"Document #" + document_two + "\" in \"Outpost Test Class\""
      $driver.find_element(:link, "Logout").click
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
