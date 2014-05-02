require "./config/initializers/browserstack"

# Set Environment Variables
ENV['ENVIRONMENT'] ||= 'production'
ENV['LOCAL'] ||= 'true'

# Outpost Specific Functions
def start_driver(cs = {})
  return $driver unless $driver == nil
  if ENV['LOCAL'] == 'true'
    $driver = Selenium::WebDriver.for :firefox
  else
    caps = Selenium::WebDriver::Remote::Capabilities.new
    cs.each do |k,v|
      caps[k] = v
    end
    caps['browser'] ||= 'Chrome'
    caps['os'] ||= 'Windows'
    caps['os_version'] ||= '8.1'
    caps['resolution'] ||= '1280x1024'
    caps[:name] ||= "Automated Testing"
    $driver = Selenium::WebDriver.for(:remote,
      :url => "http://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub.browserstack.com/wd/hub",
      :desired_capabilities => caps)
    $driver.manage().window().maximize()
  end
  $wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
  $driver
end # setup_driver

def outpost(url)
  if ENV['LOCAL'] == 'true'
    url = url.gsub('http://www.outpostqa.com/', 'http://localhost:3000/')
    $outpost = Selenium::WebDriver.for :firefox
  else
    caps = Selenium::WebDriver::Remote::Capabilities.new
    caps['browser'] = 'Firefox'
    caps['browser_version'] = '27.0'
    caps['os'] = 'Windows'
    caps['os_version'] = '8.1'
    caps[:name] = "Automated Testing - Outpost URLs"
    $outpost = Selenium::WebDriver.for(:remote,
      :url => "http://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub.browserstack.com/wd/hub",
      :desired_capabilities => caps)
  end
  $outpost.navigate.to url
  $outpost.quit
end

def start(test_id)
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/start")
end

def pass(test_id)
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/stop?status=Passed")
  #p "Passed"
end

def fail(test_id, e)
  require 'uri'
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/stop?status=Failure&message=#{URI.escape(e.inspect)}")
  p "\nFAILED: #{test_id}"
  raise
end

def skip(test_id)
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/stop?status=Skipped")
  #p "Skipped"
end


# Selenium IDE Helper Functions
def element_present?(how, what)
  $driver.find_element(how, what)
  true
rescue Selenium::WebDriver::Error::NoSuchElementError
  false
end

def alert_present?()
  $driver.switch_to.alert
  true
rescue Selenium::WebDriver::Error::NoAlertPresentError
  false
end

def close_alert_and_get_its_text(accept)
  alert = $driver.switch_to().alert()
  alert_text = alert.text
  if (accept) then
    alert.accept()
  else
    alert.dismiss()
  end
  alert_text
end
