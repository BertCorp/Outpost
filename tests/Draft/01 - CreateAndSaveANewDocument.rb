require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Create and save a new document" do

  before(:all) do
    @test_id = "7"
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
  
  it "test_1_create_and_save_a_new_document" do
    begin
      random_num = rand(1000)

      $driver = start_driver({ name: 'Draft - Automated Tests' })
      $driver.manage.timeouts.implicit_wait = 3
      
      start_logged_in

      $driver.find_element(:id, "new_document_button").click
      sleep(1)
      $driver.find_element(:id, "document_content").send_keys "This is a test document. I am testing that I can create and save a new document. #{random_num}"
      
      save_document
  
      go_home_from_document

      $driver.find_element(:css, ".document:nth-child(1) .row-fluid .span9 a.btn").click
      # Verify
      ($driver.find_element(:css, "div.document_id > p").text).should == "This is a test document. I am testing that I can create and save a new document. #{random_num}"
      
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
