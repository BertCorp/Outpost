require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "CheckoutWithCheck" do

  before(:each) do
    @test_id = "5"
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
  
  it "test_checkout_with_check" do
    begin
      start_time = Time.now
      # only allow this test to run on staging.
      if ENV['ENVIRONMENT'] == 'staging'
        #p $driver.current_url
        unless $driver.current_url.include? "checkout/onepage/"
          #p "Rerun."
          $driver.get(@base_url)
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
        end
      
        $driver.find_element(:id, "billing:manager").click
        sleep(1)
        $driver.find_element(:id, "billing:manager").find_elements( :tag_name => "option" ).find do |option|
          option.text == "I don't have one"
        end.click
        $driver.find_element(:id, "billing_firstname").clear
        $driver.find_element(:id, "billing_firstname").send_keys "Test"
        $driver.find_element(:id, "billing_lastname").clear
        $driver.find_element(:id, "billing_lastname").send_keys "Test"
        $driver.find_element(:id, "billing_email").clear
        $driver.find_element(:id, "billing_email").send_keys "test+kapow-" + Random.new.rand(11111).to_s + "@bertcorp.com"
        $driver.find_element(:id, "billing_street1").clear
        $driver.find_element(:id, "billing_street1").send_keys "1234 Maint St"
        $driver.find_element(:id, "billing_city").clear
        $driver.find_element(:id, "billing_city").send_keys "Chicago"
        $driver.find_element(:id, "billing_postcode").clear
        $driver.find_element(:id, "billing_postcode").send_keys "60647"
        $driver.find_element(:id, "billing_region_id").click
        $driver.find_element(:id, "billing_region_id").find_elements( :tag_name => "option" ).find do |option|
          option.text == "Illinois"
        end.click
        $driver.find_element(:id, "billing_telephone").clear
        $driver.find_element(:id, "billing_telephone").send_keys "8885551234"
        $driver.find_element(:id, "billing_customer_password").clear
        $driver.find_element(:id, "billing_customer_password").send_keys "test12"
        $driver.find_element(:id, "billing_confirm_password").clear
        $driver.find_element(:id, "billing_confirm_password").send_keys "test12"
        $driver.find_element(:id, "p_method_checkmo").click
        sleep(2)
        $driver.find_element(:link, "OK").click
        $driver.find_element(:id, "agreement-1").click
        $driver.find_element(:id, "submit-btn").click
        sleep(10)
        $driver.find_element(:css, ".col-main p strong").text.should =~ /^Your invoice number is [\s\S]*$/
        $driver.current_url.should =~ /^[\s\S]*\/checkout\/onepage\/success\/$/
        #$driver.get(@base_url + "customer/account/logout/")
        pass(@test_id, Time.now - start_time)
      else
        skip(@test_id, Time.now - start_time)
      end
    rescue => e
      fail(@test_id, Time.now - start_time, e)
    end
  end
  
end
