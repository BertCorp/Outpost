$environments = { production: 'http://beta.lanternhq.com/' }
$cs = { :name => 'The Starter League', 'platform' => 'OS X 10.8' }

def clear_gmail_inbox
  sign_into_gmail
  
  while $driver.find_elements(:css, "table.F > tbody > tr > td").size > 0 do
    $driver.find_element(:css, "div[data-tooltip=\"Select\"] span").click
    delete_link = $driver.find_element(:css, "div[data-tooltip=\"Delete\"]")
    if delete_link.displayed? == true
      delete_link.click
      sleep(1)
    end
    #$driver.navigate.refresh
    #close_alert_and_get_its_text(true)
    #$wait.until { $driver.find_elements(:css, "div[data-tooltip=\"Select\"] span").size > 0 }    
  end
  
  #if $driver.find_elements(:css, "table.F > tbody > tr > td").size > 0
  #  puts "Emails still in inbox: #{$driver.find_elements(:css, 'table.F > tbody > tr > td').size}"
  #end
  
  #sign_out_of_gmail
end

def click_link(link_text)
  begin
    $wait.until { $driver.find_elements(:link, link_text).size > 0 }
    desired_url = $driver.find_element(:link, link_text).attribute('href')
    initial_url = $driver.current_url
    if (desired_url != initial_url) && !desired_url.include?("#")
      while $driver.current_url == initial_url do
        $driver.find_element(:link, link_text).click
      end
    else
      $driver.find_element(:link, link_text).click
      sleep(1)
    end
    $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
  rescue => e
    # Most times, if we get an element not found error, it's because the page hasn't finished loading properly.
    # Ignore any modal windows that popped up that might be causing us an issue.
    if e.inspect.include? 'UnhandledAlertError'
      puts "Closed unexpected alert: #{close_alert_and_get_its_text(true)}"
      sleep(1)
      e.ignore
    elsif e.inspect.include? 'StaleElementReferenceError'
      # Sometimes our timing is off. Chill for a second.
      sleep(2)
      e.ignore
    elsif e.inspect.include? 'id="flash-msg"'
      # For Lantern, we have the pesky flash notification covering the logout. If we ever run into it, ignore it and just carry on.
      $driver.find_element(:css, '.alert a').click
      sleep(1)
      e.ignore
    elsif e.inspect.include? "NoSuchElementError"
      # So let's wait a few seconds and try again.
      puts "Link (#{link_text}) not present. Sleeping for 3 and retrying."
      sleep(3)
      $drive.get initial_url
      while $driver.current_url == initial_url do
        $driver.find_element(:link, link_text).click
      end
      sleep(1)
      $wait.until { !$driver.find_element(:id, 'ajax-status').displayed? }
    end
  end
end

def ensure_user_logs_out
  #puts "Before logout: #{$driver.current_url}"
  begin
    if $driver.find_elements(:id, 'flash-msg').size > 0
      $driver.find_element(:css, '.alert a').click
      sleep(1)
    end
  rescue
  end
  while $driver.find_elements(:link, "Logout").size > 0 do
    $driver.find_element(:link, "Logout").click
  end
  #puts "After logout: #{$driver.current_url}"
end

def login_as_admin
  $driver.get(@base_url + 'start')
  close_alert_and_get_its_text(true)
  
  # we aren't logged in until we are home! /start
  while $driver.find_elements(:link, 'test@outpostqa.com').size < 1 do
    # On the login page: /login and need to login:
    if $driver.find_elements(:id, "user_email").size > 0
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys "test@outpostqa.com"
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "LigReb2013"
      $driver.find_element(:name, "commit").click
      $wait.until { $driver.find_elements(:link, 'test@outpostqa.com').size > 0 }
    elsif $driver.find_elements(:link, "Learn more").size > 0
      # Homepage: http://lanternhq.com/
      $driver.find_element(:link, "Log in").click
    elsif $driver.find_elements(:link, "Logout").size > 0
      # Logged in somewhere else on the site
      ensure_user_logs_out
    elsif $driver.find_elements(:link, "Forgot your password?").size <= 0
      # Not the login page
      $driver.get(@base_url)
      $wait.until { $driver.find_elements(:link, "Learn more").size > 0 }
      $driver.find_element(:link, "Log in").click
      $wait.until { $driver.find_elements(:link, "Forgot your password?").size > 0 }
    end
  end
  # kill any flash notifications
  $driver.find_element(:css, '.alert a').click if $driver.find_elements(:id, 'flash-msg').size > 0
end

def sign_into_gmail
  #$driver.get "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en"
  $driver.get "https://mail.google.com/mail/#inbox"
  close_alert_and_get_its_text(true)
  sleep(1)
  if $driver.find_elements(:id, 'account-test@bertcorp.com').size > 0
    $driver.find_elements(:css, '#account-test@bertcorp.com > button').click
  elsif $driver.find_elements(:id, "Passwd").size > 0
    if $driver.find_element(:id, "Email").displayed?
      $driver.find_element(:id, "Email").clear
      $driver.find_element(:id, "Email").send_keys "test@bertcorp.com"
    end
    $driver.find_element(:id, "Passwd").clear
    $driver.find_element(:id, "Passwd").send_keys "LigReb2013"
    $driver.find_element(:id, "signIn").click
  end
end

def sign_out_of_gmail
  $driver.find_element(:link, "test@bertcorp.com").click
  $driver.find_element(:link, "Sign out").click
  if alert_present?
    close_alert_and_get_its_text(true)
  end
  $wait.until { $driver.find_elements(:link, "test@bertcorp.com").size < 1 }
end

def type_redactor_field(id, text)
  $wait.until { $driver.find_elements(:css, '.redactor_editor').size > 0 }
  $driver.execute_script("document.getElementsByClassName('redactor_editor')[0].innerHTML = '<p>" + text.gsub("'", "\\'") + "</p>'")
  sleep(1)
  $driver.execute_script("document.getElementById('" + id + "').style.display = 'block'")
  $driver.find_element(:id, id).clear
  $driver.find_element(:id, id).send_keys "<p>" + text + "</p>"
  sleep(2)
end

def wait_for_email
  # Click and view the latest invitation email.
  while $driver.find_elements(:css, "table.F > tbody > tr > td").size < 1 do
    if $driver.find_elements(:css, "table.F > tbody > tr > td").size < 1
      begin
        extended_wait = Selenium::WebDriver::Wait.new(:timeout => 180) # seconds
        extended_wait.until { $driver.find_elements(:css, "table.F > tbody > tr > td").size > 0 }
      rescue => e
        sleep(5)
        if $driver.find_elements(:css, "table.F > tbody > tr > td").size < 1
          sleep(60 * 5)
          e.ignore
        end
      end
    end
    # still no email? Let's come back another time.
    if $driver.find_elements(:css, "table.F > tbody > tr > td").size < 1
      begin
        raise
      rescue
        sleep(10*60)
        restart(@test_id)
        retry
      end
    end
  end
end
