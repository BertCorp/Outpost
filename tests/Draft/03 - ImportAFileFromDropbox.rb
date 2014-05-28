require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "03 - Import a file from Dropbox" do

  before(:all) do
    @test_id = "9"
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
  
  it "Import a file from Dropbox" do
    begin 
      start_logged_in
      
      begin
        $driver.find_element(:css, "#sidebar_content > div:nth-child(6) > a").click
        sleep(3)
      rescue
        $driver.execute_script("Documents.import();")
        sleep(3)
      end

      $driver.switch_to.frame('filepicker_dialog')
      $driver.find_element(:link_text, "Dropbox").click
      dropbox_link = $driver.find_element(:link, "Connect to Dropbox").attribute("href")
      #dropbox_link = $driver.find_element(:css, "#mainpane > div > div.span8.center.authpane > p:nth-child(2) > a").attribute("href")
      $driver.switch_to.default_content
      sleep(1)
      $driver.get(dropbox_link)
      sleep(10)

      # Verify
      ($driver.find_element(:class, 'login-header').text).should == 'Sign in before linking with Ink file picker'

      $driver.find_element(:xpath, '//input[@type="email"]').send_keys "test@bertcorp.com"
      $driver.find_element(:xpath, '//input[@type="password"]').send_keys "LigReb2013"
      $driver.find_element(:css, "button.login-button.button-primary").click
      $driver.find_element(:name, "allow_access").click

      $driver.get(@base_url + "documents")
      $driver.find_element(:css, "#sidebar_content > div:nth-child(6) > a").click

      $driver.switch_to.frame('filepicker_dialog')

      $driver.find_element(:link_text, "Dropbox").click

      $driver.find_element(:link, "text_upload_doc.txt").click
      $driver.find_element(:link, "Upload").click
      $driver.switch_to.default_content

      sleep(5)
      # Verify
      ($driver.find_element(:id, "document_content").text).should == "Dropbox Post -\n\nThis is a dropbox file that I am uploading to Draft to test that I can import a file"

      go_home_from_document
      
      $driver.find_element(:css, ".document:nth-child(1) .row-fluid .span9 a.btn").click

      # Verify
      ($driver.find_element(:css, '#main_content > h5').text.downcase).should == "text_upload_doc.txt"
      ($driver.find_element(:css, '#document_container > div > p:nth-child(1)').text).should == "Dropbox Post -"
      ($driver.find_element(:css, '#document_container > div > p:nth-child(2)').text).should == "This is a dropbox file that I am uploading to Draft to test that I can import a file"
      
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
        if $driver.find_element(:css, '.ic_close_modal').displayed?
          puts "Closed Intercom modal: #{$driver.find_element(:css, '.ic_close_modal').click}"
        end
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
