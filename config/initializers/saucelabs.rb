# Some stuff relating to SauceLabs.
ENV['SL_USERNAME'] ||= 'markbertrand'
ENV['SL_AUTHKEY'] ||= '6e7d8e99-318e-477f-8658-83b167f523d6'


def get_cap_declaration(browser = 'Firefox')
  if browser.downcase.include? 'firefox'
    Selenium::WebDriver::Remote::Capabilities.firefox
  elsif browser.downcase.include? 'chrome'
    Selenium::WebDriver::Remote::Capabilities.chrome
  elsif browser.downcase.include?('ie') || browser.downcase.include?('internet explorer')
    Selenium::WebDriver::Remote::Capabilities.internet_explorer
  elsif browser.downcase.include? 'safari'
    Selenium::WebDriver::Remote::Capabilities.safari
  elsif browser.downcase.include? 'opera'
    Selenium::WebDriver::Remote::Capabilities.opera
  elsif browser.downcase.include? 'iphone'
    Selenium::WebDriver::Remote::Capabilities.iphone
  elsif browser.downcase.include? 'ipad'
    Selenium::WebDriver::Remote::Capabilities.ipad
  elsif browser.downcase.include? 'android'
    Selenium::WebDriver::Remote::Capabilities.android
  else # default to Firefox if we can't find what they want
    Selenium::WebDriver::Remote::Capabilities.firefox
  end
end

def get_highest_platform(os, browser, resolution = "1280x1024")
  #Valid values for Windows XP, Windows 7, and OSX 10.6 are: "800x600", "1024x768", "1280x1024", "1440x900" and "1920x1200".
  #Valid values for OSX 10.8 are: "1024x768", "1280x1024", "1400x900", and "1920x1200".
  #Valid values for Windows 8/8.1 are "1024x768" and "1280x1024"
  if os.downcase.include? 'windows'
    if ['1024x768', '1280x1024'].include? resolution
      'Windows 8.1'
    else
      'Windows 7'
    end
  elsif os.downcase.include?('mac') || os.downcase.include?('os x')
    if (browser.downcase == 'chrome') && ["1024x768", "1280x1024", "1400x900", "1920x1200"].include?(resolution)
      'OS X 10.8'
    else
      'OS X 10.6'
    end
  else
    nil
  end
end

def get_browser_resolutions(platform)
  if ['windows xp', 'windows 7', 'os x 10.6'].include? platform
    ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
  elsif ['os x 10.8'].include? platform
    ["1024x768", "1280x1024", "1400x900", "1920x1200"]
  elsif ['windows 8', 'windows 8.1'].include? platform
    ["1024x768", "1280x1024"]
  else
    []
  end
end


SL_BROWSERS = {
	'Chrome (Mac)' => {
		browser_name: 'Chrome',
		platform: 'OS X 10.6',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},	
  'Chrome (PC)' => {
		browser_name: 'Chrome',
		platform: 'Windows 7',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},
	'Firefox (Mac)' => {
		browser_name: 'Firefox',
		platform: 'OS X 10.6',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},
	'Firefox (PC)' => {
		browser_name: 'Firefox',
		platform: 'Windows 7',
		resolution: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},
	'Safari' => {
		browser_name: 'Safari',
		platform: 'OS X 10.6',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},
	'IE8' => {
		browser_name: 'IE',
		version: '8.0',
		platform: 'Windows 7',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},
	'IE9' => {
		browser_name: 'IE',
		version: '9.0',
		platform: 'Windows 7',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},
	'IE10' => {
		browser_name: 'IE',
		version: '10.0',
		platform: 'Windows 8',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	},
	'IE11' => {
		browser_name: 'IE',
		version: '11.0',
		platform: 'Windows 8.1',
		resolutions: ["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
	}
}
