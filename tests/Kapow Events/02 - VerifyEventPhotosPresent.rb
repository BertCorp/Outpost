require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "VerifyEventPhotosPresentProduction" do

  before(:each) do
    @test_id = "3"
    start(@test_id)
    $driver = start_driver({ name: 'Kapow Events - Automated Tests' })
    $driver.manage.timeouts.implicit_wait = 3
    @base_url = @base_url_orig = $environments[ENV["ENVIRONMENT"].to_sym]
    if $credentials[ENV['ENVIRONMENT'].to_sym]
      base_url_pieces = @base_url.split('://')
      @base_url = base_url_pieces[0] + '://' + $credentials[ENV['ENVIRONMENT'].to_sym][:username] + ":" + $credentials[ENV['ENVIRONMENT'].to_sym][:password] + "@" + base_url_pieces[1]
      #p @base_url
    end
  end
  
  after(:all) do
    # if this is really the end... then quit.
    $driver.quit unless $is_test_suite
  end
  
  it "test_home_page_blog_posts" do
    begin
      start_time = Time.now
      $driver.get @base_url
      $driver.find_element(:link_text, "ALL EVENTS").click
    
      # Check for specific number of events?
      #($driver.find_elements(:css, "#eventlist_events_container li").size).should == 30
    
      images_to_check = []
    
      $driver.find_elements(:css, '#eventlist_events_container li').each do |li|
        #p li.find_element(:css, '.eventlist_event_image').inspect
        style = li.find_element(:css, '.eventlist_event_image').attribute("style")
        image = style.split(@base_url_orig)[1].split("\"")[0]
        images_to_check << @base_url + image
      end
    
      images_to_check.each do |image|
        #p image
        $driver.get(image)
        ($driver.find_elements(:css, 'img').first.attribute('src')).should == image
        $driver.current_url.should_not =~ /^[\s\S]*\/placeholder\/[\s\S]*$/
        $driver.navigate.back
      end
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
