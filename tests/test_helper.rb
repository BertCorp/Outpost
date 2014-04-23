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
  $driver
end # setup_driver

def outpost(url)
  url = url.gsub('http://www.outpostqa.com/', 'http://localhost:3000/')
  #p url
  if ENV['LOCAL'] == 'true'
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

def pass(test_id, execution_time)
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/stop?status=Passed&execution=#{execution_time.to_s}")
  #p "Executed successfully: #{execution_time.to_s}"
end

def fail(test_id, execution_time, e)
  require 'uri'
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/stop?status=Failure&execution=#{execution_time.to_s}&message=#{URI.escape(e.inspect)}")
  p "\nFAILED: #{test_id}\n"
  raise
end

def skip(test_id, execution_time)
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/stop?status=Skipped&execution=0.0")
  #p "Skipped: #{execution_time.to_s}"
end


# Selenium IDE Helper Functions
def element_present?(how, what)
  @driver.find_element(how, what)
  true
rescue Selenium::WebDriver::Error::NoSuchElementError
  false
end

def alert_present?()
  @driver.switch_to.alert
  true
rescue Selenium::WebDriver::Error::NoAlertPresentError
  false
end

def verify(&blk)
  yield
rescue => ex
  @verification_errors << ex
end

def close_alert_and_get_its_text(how, what)
  alert = @driver.switch_to().alert()
  alert_text = alert.text
  if (@accept_next_alert) then
    alert.accept()
  else
    alert.dismiss()
  end
  alert_text
ensure
  @accept_next_alert = true
end
