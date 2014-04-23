require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "HomePageBlogPosts" do

  before(:each) do
    @test_id = "2"
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
      ($driver.find_elements(:css, "li.item").size).should == 8
      ($driver.find_elements(:css, "a.featured-image").size).should == 8
      ($driver.find_elements(:css, "div.success_header").size).should == 8
    
      (1..8).each do |i|
        style = $driver.find_element(:css, "li.item:nth-child(" + i.to_s + ") > a.featured-image").attribute("style")      
        image = style.split(@base_url_orig)[1].split("\"")[0]
        #p @base_url + image
        $driver.get(@base_url + image)
        ($driver.find_elements(:css, 'img').first.attribute('src')).should == @base_url + image
        $driver.navigate.back      
      end
      pass(@test_id, Time.now - start_time)
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
