require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Create and save a new document" do

  before(:each) do
    @test_id = "7"
    start(@test_id)
    $driver = start_driver({ name: 'Draft - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_1_create_and_save_a_new_document" do
    begin
      start_time = Time.now
      random_num = rand(1000)
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds

      start_logged_in

      $driver.find_element(:id, "new_document_button").click
      sleep(1)
      $driver.find_element(:id, "document_content").send_keys "This is a test document. I am testing that I can create and save a new document. #{random_num}"
      
      save_document
  
      go_home_from_document

      $driver.find_element(:css, ".document:nth-child(1) .row-fluid .span9 a.btn").click
      # Verify
      ($driver.find_element(:css, "div.document_id > p").text).should == "This is a test document. I am testing that I can create and save a new document. #{random_num}"
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
