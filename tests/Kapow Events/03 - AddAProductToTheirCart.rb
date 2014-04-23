require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "AddAProductToTheirCart" do

  before(:each) do
    @test_id = "4"
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
  
  it "test_add_a_product_to_their_cart" do
    begin
      start_time = Time.now
      # only allow this test to run on staging.
      if ENV['ENVIRONMENT'] == 'staging'
        $driver.navigate.to(@base_url)
        $driver.find_element(:link_text, "ALL EVENTS").click

        $driver.find_element(:css, ".eventlist_products:nth-child(1) a").click
        $driver.find_element(:css, 'input[type=radio]:nth-child(1)').click

        unless $driver.find_elements(:css, '.Zebra_DatePicker_Icon').size == 0
          $driver.find_element(:css, '.Zebra_DatePicker_Icon').click
          if $driver.find_elements(:css, '.dp_daypicker .dp_current').size == 0
            $driver.find_element(:css, '.dp_daypicker .dp_selected').click
          else
            $driver.find_element(:css, '.dp_daypicker .dp_current').click
          end
        end

        $driver.find_element(:id, "add_to_cart_large").click
        ($driver.find_element(:css, "h2.glc-title:nth-child(1) strong").text.downcase).should == "Billing address".downcase
        $driver.current_url.should =~ /^[\s\S]*\/checkout\/onepage\/$/
        pass(@test_id, Time.now - start_time)
      else
        skip(@test_id, Time.now - start_time)
      end
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
