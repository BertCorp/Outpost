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
    @tries = []
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
      # For Draft, we have this pesky Intercom modal that causes issues. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="IModalOverlay"'
        $driver.find_element(:css, '.ic_close_modal').click
        sleep(3)
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
      puts e.backtrace.join("\n") unless $is_test_suite
      puts "Retrying `#{self.class.description}`: #{@tries.count}"
      puts ""
      retry if @tries.count < 3 && $is_test_suite
      fail(@test_id, e)
    end
  end
  
end
