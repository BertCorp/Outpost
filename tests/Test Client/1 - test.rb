require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"

describe "Client Test #1" do
  before(:all) do
    @base_url = "http://reviewtrackers.com"
    @accept_next_alert = true
    # @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  after(:all) do
    @driver.quit unless @driver == nil
    @verification_errors.should == []
  end
  
  it "should be something really simple" do
    verify { @base_url.should == 'http://reviewtrackers.com' }
  end
  
end
