$environments = { production: 'http://reviewtrackers.com' }
$cs = { :name => 'Review Trackers' }

$to_test = [
  { browser: 'Firefox (Mac)', resolution: '1280x1024', name: '{{name}}/{{browser}}-{{resolution}}' },
  { browser: 'Chrome (Mac)', resolution: '1280x1024', name: '{{name}}/{{browser}}-{{resolution}}' },
  { browser: 'Safari', resolution: '1280x1024', name: '{{name}}/{{browser}}-{{resolution}}'},
  { browser: 'IE8', resolution: '1280x1024', name: '{{name}}/{{browser}}-{{resolution}}' },
  { browser: 'IE9', resolution: '1280x1024', name: '{{name}}/{{browser}}-{{resolution}}' },
  { browser: 'IE10', resolution: '1280x1024', name: '{{name}}/{{browser}}-{{resolution}}' },
  { browser: 'IE11', resolution: '1280x1024', name: '{{name}}/{{browser}}-{{resolution}}' },

  { resolution: "800x600", browser: 'Firefox (Mac)', name: '{{name}}/{{resolution}}-{{browser}}' },
  { resolution: "1024x768", browser: 'Firefox (Mac)', name: '{{name}}/{{resolution}}-{{browser}}' },
  #{ resolution: "1280x1024", browser: 'Firefox (Mac)', name: '{{name}}/{{resolution}}-{{browser}}' },
  { resolution: "1440x900", browser: 'Firefox (Mac)', name: '{{name}}/{{resolution}}-{{browser}}' },
  { resolution: "1920x1200", browser: 'Firefox (Mac)', name: '{{name}}/{{resolution}}-{{browser}}' },

  { device: 'iPhone', version: '7.1', name: '{{name}}/{{device}}-{{version}}' },
  { device: 'iPad', version: '7.1', name: '{{name}}/{{device}}-{{version}}' }
]

$login = {
  url: 'https://secure.reviewtrackers.com/users/sign_in',
  steps: [
    { 'send_keys' => { '#user_email' => "demo@reviewtrackers.com" } },
    { 'send_keys' => { '#user_password' => "trackmyreviews" } },
    { 'click' => 'button' }
  ]
}


$urls = {
  'homepage' => { url: 'http://www.reviewtrackers.com/', login: false },
  'marketing/tour' => { url: 'http://www.reviewtrackers.com/tour', login: false },
  'marketing/pricing' => { url: 'http://www.reviewtrackers.com/pricing', login: false },
  'marketing/blog' => { url: 'http://www.reviewtrackers.com/blog', login: false },
  'marketing/contact' => { url: 'http://www.reviewtrackers.com/contact', login: false },
  'marketing/blog-post' => { url: 'http://www.reviewtrackers.com/91-percent-women-research-online-influenced-reviews-making-purchase/', login: false },
  'marketing/landing-page' => { url: 'http://www.reviewtrackers.com/lp/', login: false },
  
  'login' => { url: 'https://secure.reviewtrackers.com/users/sign_in', login: false },
  'dashboard' => { url: 'https://secure.reviewtrackers.com/account_dashboard', login: true},
  'new-review' => { url: 'https://secure.reviewtrackers.com/request_reviews/new', login: true }, 
  'request-template' => { url: 'https://secure.reviewtrackers.com/request_templates/new', login: true },
  'settings' => { url: 'https://secure.reviewtrackers.com/settings/15/edit', login: true }, 
  'review' => { url: 'https://secure.reviewtrackers.com/reviews/407976', login: true }
}

def establish_driver(test)
  return $driver if $driver && ($driver != nil)
  $driver = nil
  puts ""
  print "** Establish driver for "
  if test[:device]
    caps = get_cap_declaration(test[:device])
    caps.platform = 'OS X 10.9'
    caps.version = test[:version]
    caps['browser'] = test[:device]
    caps['device-orientation'] = 'portrait'
    caps[:takes_screenshot] = true
    caps[:name] = "Review Trackers - #{test[:device]}"
    puts "#{test[:device]} v#{test[:version]} **"
  elsif test[:browser]
    caps = get_cap_declaration(test[:browser])
    caps.platform = SL_BROWSERS[test[:browser]][:platform]
    caps.version = SL_BROWSERS[test[:browser]][:version] if SL_BROWSERS[test[:browser]][:version]
    caps['screen-resolution'] = (test[:resolution]) ? test[:resolution] : "1280x1024"
    caps["iedriver-version"] = "x64_2.41.0" if test[:browser].downcase.include?('ie') && test[:browser].downcase != 'ie9'
    caps[:name] = "Review Trackers - #{test[:resolution]}"
    puts "#{test[:browser]} @ #{test[:resolution]} **"
  end
  #puts caps.inspect
  #puts ""
  caps["public"] = "share"
  puts caps.inspect
  print "Driver started: "
  puts $driver = Selenium::WebDriver.for(
    :remote,
    :url => "http://#{ENV['SL_USERNAME']}:#{ENV['SL_AUTHKEY']}@ondemand.saucelabs.com:80/wd/hub",
    :desired_capabilities => caps
  )
  $driver.manage.timeouts.implicit_wait = 3
  begin
    $driver.manage.window.maximize
  rescue
  end
  $wait = Selenium::WebDriver::Wait.new(:timeout => 15) # seconds
  $driver
end

def screenshot_already_exists?(test, name)
  File.exists?(screenshot_path(test, name))
end
  
def screenshot_path(test, name)  
  require 'fileutils'
  url = File.dirname(__FILE__) + "/screenshots/#{Date.today}/" + test[:name] + ".png"
  url = url.gsub("{{name}}", name)
  url = url.gsub("{{browser}}", test[:browser]) if test[:browser]
  url = url.gsub("{{resolution}}", test[:resolution]) if test[:resolution]
  url = url.gsub("{{device}}", test[:device]) if test[:device]
  url = url.gsub("{{version}}", test[:version]) if test[:version]
  FileUtils::mkdir_p File.dirname(url)
  url
end

def take_screenshot(test, name, info)
  begin
    $driver = establish_driver(test)
    $driver.get info[:url]
    sleep(2)
    puts "Initial URL: #{$driver.current_url}"

    # Check to see if we need to be signed in to access this page
    if (info[:login] === true) || ($driver.current_url.chomp('/') != info[:url].chomp('/'))
      # head to signin page
      if (info[:login] === true)
        puts "User requested login"
        $driver.get $login[:url]
        sleep(2)
      elsif ($login[:url].chomp('/') != $driver.current_url.chomp('/'))
        puts "Page needs to be logged in"
        $driver.get $login[:url]
        sleep(2)
      end

      if ($login[:url].chomp('/') == $driver.current_url.chomp('/'))
        puts "Needs to be logged in, following login steps"
        # follow signin steps
        $login[:steps].each do |step|
          puts step.inspect
          if step['send_keys']
            puts step['send_keys'].inspect
            if test[:browser].downcase.include? 'ie'
              $driver.execute_script("document.getElementById('#{step['send_keys'].keys.first.gsub('#', '')}').value = '#{step['send_keys'].values.first}';")
            else
              $driver.find_element(:css, step['send_keys'].keys.first).send_keys(step['send_keys'].values.first)
            end
          elsif step['click']
            $driver.find_element(:css, step['click']).click
            $wait.until { $driver.current_url.chomp('/') != $login[:url].chomp('/') }
            sleep(2)
          end
        end
        puts "After Login URL: #{$driver.current_url}"
      else
        puts "Already logged in"
      end
      if $driver.current_url.chomp('/') != info[:url].chomp('/')
        $driver.get info[:url]
        sleep(2)
      end
    end

    $driver.save_screenshot screenshot_path(test, name)
  rescue => e
    if ["#<Net::ReadTimeout: Net::ReadTimeout>", "#<Errno::ECONNREFUSED: Connection refused - connect(2)>", "#<EOFError: end of file reached>"].include? e.inspect
        puts "Retrying in 3 seconds because of: #{e.inspect}"
        $driver.quit if $driver && ($driver != nil)
        $driver = nil
        sleep(3)
        take_screenshot(test, name, info)
    else
      raise
    end
  end
end

