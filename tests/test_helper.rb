require "./config/initializers/saucelabs"
require "./tests/ignorable"

# Set Environment Variables
ENV['ENVIRONMENT'] ||= 'production'
ENV['LOCAL'] ||= 'true'

# Outpost Specific Functions
def start_driver(cs = {})
  return $driver unless $driver == nil
  if ENV['LOCAL'] == 'true'
    $driver = Selenium::WebDriver.for :firefox
  else
    if cs['browser']
      browser = cs['browser']
      cs.delete('browser')
    end
    browser ||= 'Chrome'
    caps = get_cap_declaration(browser)
    cs.each do |k,v|
      caps[k] = v
    end
    caps["platform"] ||= 'OS X 10.8'
    caps["version"] ||= ''
    caps["screen-resolution"] ||= '1280x1024'
    $driver = Selenium::WebDriver.for(
      :remote,
      :url => "http://#{ENV['SL_USERNAME']}:#{ENV['SL_AUTHKEY']}@ondemand.saucelabs.com:80/wd/hub",
      :desired_capabilities => caps
    )
    $driver.manage().window().maximize()
    #$driver.file_detector = lambda do |args|
    #  str = args.first.to_s
    #  str if File.exist?(str)
    #end
  end
  $wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds
  $driver
end # setup_driver

def outpost(url)
  begin
    url = url.gsub('http://www.outpostqa.com/', 'http://outpost.dev') if ENV['LOCAL'] == 'true'
    unless $outpost
      if ENV['LOCAL'] == 'true'
        $outpost = Selenium::WebDriver.for :firefox
      else
        caps = get_cap_declaration('firefox')
        caps["platform"] = 'Windows 8.1'
        caps["version"] = '27'
        caps["screen-resolution"] = '1280x1024'
        $driver = Selenium::WebDriver.for(
          :remote,
          :url => "http://#{ENV['SL_USERNAME']}:#{ENV['SL_AUTHKEY']}@ondemand.saucelabs.com:80/wd/hub",
          :desired_capabilities => caps
        )
      end
    end
    $outpost.navigate.to url
  rescue => e
    if e.inspect.include? "Session not started"
      "Session missing. Retrying to restart in 5."
      $outpost = nil
      sleep(5)
      outpost(url)
    end
  end
end

def start(test_id)
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/start")
  sleep(2)
  $outpost.quit if $outpost
  $outpost = nil
end

def restart(test_id)
  outpost("http://www.outpostqa.com/admin/tests/#{test_id}/restart")
  sleep(1)
  $outpost.quit if $outpost
  $outpost = nil
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
  $driver.find_elements(how, what).size > 0
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
