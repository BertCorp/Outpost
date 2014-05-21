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
    @tries = []
    start(@test_id)
  end
  
  after(:all) do
    # if this is really the end... then quit.
    unless $is_test_suite
      $driver.quit if $driver
      $outpost.quit if $outpost
    end
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
      if e.inspect.include? 'UnhandledAlertError'
        puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
        sleep(1)
        e.ignore
      end
      # For Draft, we have this pesky Intercom modal that causes issues. If we ever run into it, ignore it and just carry on.
      if e.inspect.include? 'id="IModalOverlay"'
        puts "Closed Intercom modal: #{$driver.find_element(:css, '.ic_close_modal').click}"
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
