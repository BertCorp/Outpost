require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "CheckoutWithCheck" do

  before(:each) do
    @test_id = "25"
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
    $driver.quit #unless $is_test_suite
  end
  
  it "test_custom_option_updates_price" do
    begin
      start_time = Time.now
      # only allow this test to run on staging.
      if ENV['ENVIRONMENT'] == 'staging'
        $driver.get "http://mirror.kapowevents.com/3639-wrigley-rooftop"
        # ERROR: Caught exception [ReferenceError: selectLocator is not defined]
        ($driver.find_element(:css, "span.price").text).should == "$85.00"
        $driver.find_element(:id, "qty").clear
        $driver.find_element(:id, "qty").send_keys "10"
        $driver.find_element(:id, "add_to_cart_large").click
        ($driver.find_element(:css, "span.cart-price > span.price").text).should == "$85.00"
        # ERROR: Caught exception [ERROR: Unsupported command [selectWindow | null | ]]
        ($driver.find_element(:css, "span.gcheckout-qty").text).should == "10"
        ($driver.find_element(:css, "td.a-right.last > span.cart-price > span.price").text).should == "$850.00"
        $driver.find_element(:css, "span.glc-ico.ico-del").click
        ($driver.find_element(:css, "h2").text).should == "You don't have any events to book yet."
        pass(@test_id, Time.now - start_time)
      else
        skip(@test_id, Time.now - start_time)
      end
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
