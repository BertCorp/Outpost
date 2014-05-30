require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "02 - Edit and save an existing document" do

  before(:all) do
    @test_id = "8"
    print "** Starting: #{self.class.description} (Test ##{@test_id}) **"
  end

  before(:each) do |x|
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    @tries = []
    $driver = start_driver()
    start(@test_id)
    puts ""
    print "#{x.example.description}: "
  end
  
  after(:all) do
    # if this is really the end... then quit.
    puts ""
    puts "** Finished: #{self.class.description} **"
    unless $is_test_suite
      $driver.quit
    end
  end
  
  it "Edit and Save Existing Document" do
    begin
      random_num = rand(1000)
      
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
