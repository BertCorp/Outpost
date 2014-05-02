require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Edit a document and save" do

  before(:all) do
    @test_id = "8"
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @retry_count = 0
    start(@test_id)
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_2_edit_a_document_and_save" do
    begin
      random_num = rand(1000)
      
      $driver = start_driver({ name: 'Draft - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      
      start_logged_in
      
      if $driver.find_elements(:css, '.document').size < 1
        # create a new document if there isn't one.
        $driver.find_element(:id, "new_document_button").click
        $driver.find_element(:id, "document_content").send_keys "Creating a new document that we will edited. #{random_num}"
        save_document
        
        go_home_from_document
      end

      $driver.find_element(:css, ".document:nth-child(1) .btn-group a.btn-danger").click
      $driver.find_element(:class, "document_content_text").clear
      $driver.find_element(:class, "document_content_text").send_keys "This is a test document. I am testing that I can edit the document that i created in the draft composer. #{random_num}" 
      
      save_document

      go_home_from_document
      
      $driver.find_element(:css, ".document:nth-child(1) .row-fluid div.span9 div div a.btn").click
      # Verify
      $driver.find_element(:css, "div.document_id > p").text.should == "This is a test document. I am testing that I can edit the document that i created in the draft composer. #{random_num}"
      
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
