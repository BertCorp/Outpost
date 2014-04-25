require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Share, Merge and Reject" do

  before(:each) do
    @test_id = "10"
    start(@test_id)
    $driver = start_driver({ name: 'Draft - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_4_share_merge_and_reject" do
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
      wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds

      # just create a new document for this
      $driver.find_element(:id, "new_document_button").click
      $driver.find_element(:id, "document_content").send_keys "Creating a new document that we will share. #{random_num}"
      #$post_id =  $driver.find_element(:class, 'distraction_free_form').attribute("data-document-id")
      edit_menu = $driver.find_element(:id, "edit_menu")
      $driver.action.move_to(edit_menu).perform
      begin
        wait.until { $driver.find_element(:id, "mark_draft_button").displayed? }
        $driver.find_element(:id, "mark_draft_button").click #if element_present?(:id, "mark_draft_button") && $driver.find_element(:id, "mark_draft_button").displayed?
      rescue
      end
      sleep(1)
      # Verify
      $driver.find_element(:id, "saving_indicator").text.should == "SAVED"

      sleep(1)
      home_button_expander = $driver.find_element(:id, 'home_button')
      $driver.action.move_to(home_button_expander).perform
      wait.until { $driver.find_element(:id, "home_link").displayed? }
      $driver.find_element(:id, "home_link").click
      $driver.get(@base_url + 'documents/') unless $driver.current_url ==  @base_url + 'documents'

      sleep(3)
      $driver.find_element(:css, ".document:nth-child(1) .row-fluid .span9 a.btn").click
      sleep(1)
      $driver.find_element(:css, "#sidebar_content > div:nth-child(5) a:nth-child(1)").click

      share_link = $driver.find_element(:css, "#share_url").text

      # $driver.find_element(:link, "Or email someone to help edit your document.").click
      # $driver.find_element(:id, "email_invitation_email").clear
      # $driver.find_element(:id, "email_invitation_email").send_keys "test+draft_editor@bertcorp.com"
      # $driver.find_element(:id, "email_invitation_message").clear
      # $driver.find_element(:id, "email_invitation_message").send_keys "Can you edit this document?"
      # $driver.find_element(:name, "commit").click
      # 
      # $driver.find_element(:css, '#sidebar_content > h5 > a').click
      
      
      $driver.find_element(:css, '#invite_link > div > a').click
      sleep(1)
      $driver.find_element(:link_text, "LOGOUT").click
      $driver.find_element(:css, "#homepage_titles > h1").text.should == "WRITE BETTER WITH DRAFT"

      # gmail
      # $driver.get "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en"
      # $driver.find_element(:id, "Email").clear
      # $driver.find_element(:id, "Email").send_keys "test@bertcorp.com"
      # $driver.find_element(:id, "Passwd").clear
      # $driver.find_element(:id, "Passwd").send_keys "LigReb2013"
      # $driver.find_element(:id, "signIn").click
      # 
      # wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      # wait.until { ($driver.find_element(:css, "span:contains(\"would like your help editing a document.\"):first")).displayed? == true }
      # 
      # $driver.find_element(:css, "span:contains(\"would like your help editing a document.\"):first").click
      # edit_link = $driver.find_element(:css, "a:contains(\"https://draftin.com/documents/\")").attribute("href")
      # p edit_link
      # $driver.get(@base_url + edit_link)

      $driver.get(share_link)
      $driver.find_element(:css, "#sidebar_content div.instruction_copy a.btn").click
      sleep(1)
      $driver.find_element(:link_text, "LOGIN").click
      sleep(1)
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft_editor@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").send_keys "testcase12"
      $driver.find_element(:name, "commit").click

      if element_present?(:css, "#sidebar_content div.instruction_copy a.btn")
        $driver.find_element(:css, "#sidebar_content div.instruction_copy a.btn").click
      end
      
      $driver.find_element(:id, "document_content").clear
      $driver.find_element(:id, "document_content").send_keys "I edited the document that i created in the draft composer. I am a friend editing this document. #{random_num}"
      edit_menu = $driver.find_element(:id, "edit_menu")
      $driver.action.move_to(edit_menu).perform
      begin
        wait.until { $driver.find_element(:id, "mark_draft_button").displayed? }
        $driver.find_element(:id, "mark_draft_button").click #if element_present?(:id, "mark_draft_button") && $driver.find_element(:id, "mark_draft_button").displayed?
      rescue
      end
      sleep(1)
      # Verify
      ($driver.find_element(:id, "saving_indicator").text).should == "SAVED"
      sleep(1)

      $driver.find_element(:css, "#done_editing_button").click
      $driver.find_element(:id, "note").clear
      $driver.find_element(:id, "note").send_keys "I edited this document."
      $driver.find_element(:css, "form > input[name=\"commit\"]").click
      close_alert_and_get_its_text(true) if alert_present?
      $driver.find_element(:link, "LOGOUT").click

      $driver.find_element(:link, "LOGIN").click
      $driver.find_element(:id, "draft_user_email").clear
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").clear
      $driver.find_element(:id, "draft_user_password").send_keys "changeme"
      $driver.find_element(:name, "commit").click

      $driver.find_element(:css, ".document:nth-child(1) .commands a").click
      sleep(1)
      $driver.find_element(:link, "ACCEPT CHANGE").click
      sleep(2)

      $driver.find_element(:id, "home_button_drafts").click
      $driver.find_element(:css, ".document:nth-child(1) .row-fluid .span9 a.btn").click
      ($driver.find_element(:css, "#document_container > div > p").text).should == "I edited the document that i created in the draft composer. I am a friend editing this document. #{random_num}"
      $driver.find_element(:link, "LOGOUT").click

      $driver.find_element(:link, "LOGIN").click
      $driver.find_element(:id, "draft_user_email").clear
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft_editor@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").clear
      $driver.find_element(:id, "draft_user_password").send_keys "testcase12"
      $driver.find_element(:name, "commit").click
      $driver.find_element(:link, "EDIT").click
      $driver.find_element(:id, "document_content").clear
      $driver.find_element(:id, "document_content").send_keys "I edited the document that i created in the draft composer. I am a friend editing this document. #{random_num} Here is another change to this document."

      edit_menu = $driver.find_element(:id, "edit_menu")
      $driver.action.move_to(edit_menu).perform
      #$driver.find_element(:id, "mark_draft_button").click if element_present?(:id, "mark_draft_button")
      sleep(1)
      # Verify
      ($driver.find_element(:id, "saving_indicator").text).should == "SAVED"

      sleep(1)
      $driver.find_element(:css, "#done_editing_button").click
      $driver.find_element(:id, "note").clear
      $driver.find_element(:id, "note").send_keys "Here is my second change to ignore."
      $driver.find_element(:css, "form > input[name=\"commit\"]").click
      sleep(1)
      $driver.find_element(:link, "VIEW").click
      sleep(1)
      # Verify
      ($driver.find_element(:css, "#document_container > div > p").text).should == "I edited the document that i created in the draft composer. I am a friend editing this document. #{random_num} Here is another change to this document."
      
      $driver.find_element(:link, "LOGOUT").click
      $driver.find_element(:link, "LOGIN").click
      $driver.find_element(:id, "draft_user_email").clear
      $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
      $driver.find_element(:id, "draft_user_password").clear
      $driver.find_element(:id, "draft_user_password").send_keys "changeme"
      $driver.find_element(:name, "commit").click
      #$driver.find_element(:link, "1 COLLABORATOR").click
      $driver.find_element(:css, ".document:nth-child(1) .commands a").click
      $driver.find_element(:link, "IGNORE").click
      $driver.find_element(:css, "i.icon-home").click
      sleep(1)
      $driver.find_element(:link, "VIEW").click
      sleep(1)
      ($driver.find_element(:css, "#document_container > div > p").text).should == "I edited the document that i created in the draft composer. I am a friend editing this document. #{random_num}"
      $driver.find_element(:link, "LOGOUT").click
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
