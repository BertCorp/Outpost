require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'

#require "./config/initializers/browserstack.rb"
require "./config/environment"

describe "Client Tests" do
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
  
  it "test 1" do
    #puts BS_BROWSERS.inspect
    caps = Selenium::WebDriver::Remote::Capabilities.new
    caps['browser'] = 'Firefox'
    caps['browser_version'] = '27.0'
    caps['os'] = 'Windows'
    caps['os_version'] = '8.1'
    caps['resolution'] = '1280x1024'
    caps[:name] = "Testing Selenium 2 with Ruby on BrowserStack"
    @driver = Selenium::WebDriver.for(:remote,
      :url => "http://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub.browserstack.com/wd/hub",
      :desired_capabilities => caps)
    @driver.manage().window().maximize()
    @driver.get(@base_url)
    #puts File.dirname(__FILE__) + "/test.png"
    #puts @driver.title
    @driver.save_screenshot(File.dirname(__FILE__) + "/test.png")
    @driver.quit
    #return title
  end
  
end
