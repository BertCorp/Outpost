require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Test Homepage Loads" do

  before(:each) do
    @test_id = "32"
    start(@test_id)
    $driver = start_driver({ name: 'Outpost - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_1_test_homepage_loads" do
    begin
      start_time = Time.now
      $driver.get(@base_url)
      # Verify
      element_present?(:css, "img[alt=\"Outpost\"]").should be_true
      # Verify
      ($driver.find_element(:css, "h1").text).should == "You can't fix it if you don't know it's broken."
      # Verify
      $driver.find_element(:css, "p").text.should =~ /^exact:Outpost is a new QA and testing consultancy that helps you and your team be more confident when deploying new code\. Whether you're a PM, a developer, designer, CEO or single founder, we all know things break\. Remember that last time you deployed and didn't catch that error until days later[\s\S] We are here to help you discover those bugs and errors before your customers do and you lose that conversion\. We want you to get back to building faster and worrying less\.$/
      $driver.find_element(:id, "fieldEmail").clear
      $driver.find_element(:id, "fieldEmail").send_keys "mark_test@outpostqa.com"
      $driver.find_element(:css, "button.btn.btn-success").click
      # Verify
      ($driver.find_element(:css, "img[alt=\"Outpost\"]").text).should == ""
      # Verify
      ($driver.find_element(:xpath, "//div[@id='marketing-page']/div/div/p[2]").text).should == "Our team has been notified and will be in touch with you shortly about next steps."
      
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
