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
      $driver.get(@base_url + 'documents')
      # login, if we aren't already
      if $driver.current_url.include? "draft/users/sign_in"
        $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
        $driver.find_element(:id, "draft_user_password").send_keys "changeme"
        $driver.find_element(:name, "commit").click
      end

      random_num = rand(1000)

      $driver.find_element(:id, "new_document_button").click
      sleep(1)
      $driver.find_element(:id, "document_content").send_keys "This is a test document. I am testing that I can create and save a new document. #{random_num}"
      #$post_id =  $driver.find_element(:class, 'distraction_free_form').attribute("data-document-id")
      edit_menu = $driver.find_element(:id, "edit_menu")
      $driver.action.move_to(edit_menu).perform
      $driver.find_element(:id, "mark_draft_button").click
      sleep(1)
      # Verify
      $driver.find_element(:id, "saving_indicator").text.should == "SAVED"
  
      sleep(1)
      home_button_expander = $driver.find_element(:id, 'home_button')
      $driver.action.move_to(home_button_expander).perform
      sleep(2)
      $driver.find_element(:id, "home_link").click
      $driver.get(@base_url + 'documents/') unless $driver.current_url ==  @base_url + 'documents'

      sleep(3)
      $driver.find_element(:css, ".document:nth-child(1) .row-fluid div.span9 div div a.btn").click
      # Verify
      ($driver.find_element(:css, "div.document_id > p").text).should == "This is a test document. I am testing that I can create and save a new document. #{random_num}"
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
