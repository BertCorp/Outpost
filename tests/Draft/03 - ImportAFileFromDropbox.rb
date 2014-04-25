require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Import a file from Dropbox" do

  before(:each) do
    @test_id = "9"
    start(@test_id)
    $driver = start_driver({ name: 'Draft - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_3_import_a_file_from_dropbox" do
    begin
      start_time = Time.now
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
      
      start_logged_in
      
      $driver.find_element(:css, "#sidebar_content > div:nth-child(6) > a").click
      sleep(3)

      $driver.switch_to.frame('filepicker_dialog')

      $driver.find_element(:link_text, "Dropbox").click
      dropbox_link = $driver.find_element(:css, "#mainpane > div > div.span8.center.authpane > p:nth-child(2) > a").attribute("href")
      $driver.switch_to.default_content
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
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
