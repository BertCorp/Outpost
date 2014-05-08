$environments = { production: "http://lanternhq.com/" }

def clear_gmail_inbox
  sign_into_gmail
  
  $driver.find_element(:css, "div[data-tooltip=\"Select\"] span").click
  delete_link = $driver.find_element(:css, "div[data-tooltip=\"Delete\"]")
  if delete_link.displayed? == true
    delete_link.click
  end
  
  sign_out_of_gmail
end

def login_as_admin
  # go to homepage (http://lanternhq.com/) and login.
  $driver.get(@base_url) unless $driver.current_url == @base_url
  
  puts "Troubleshoot Login:"
  puts "Current URL: #{$driver.current_url} (20)"
  puts "Click `Log in`"
  $driver.find_element(:link, "Log in").click
  puts "Current URL: #{$driver.current_url} (23)"
  
  # we aren't logged in until we are home! /start
  puts "Start looping to find `test@outpostqa.com` link."
  puts "Current URL: #{$driver.current_url} (27)"
  while $driver.find_elements(:link, 'test@outpostqa.com').size < 1 do
    # Homepage: http://lanternhq.com/
    if $driver.find_elements(:link, "Learn more").size > 0
      puts "`Learn more` link is present! Click `Log in` link"
      $driver.find_element(:link, "Log in").click
      puts "Current URL: #{$driver.current_url} (33)"
    # Logged in somewhere else on the site
    elsif $driver.find_elements(:link, "Logout").size > 0
      puts "Current URL: #{$driver.current_url} (36)"
      puts "`Logout` link is present. Click it!"
      $driver.find_element(:link, "Logout").click
      puts "Current URL: #{$driver.current_url} (39)"
      if $driver.find_elements(:link, "Logout").size > 0
        puts "`Logout` link is STILL present. Click it again!"
        $driver.find_element(:link, "Logout").click 
        puts "Current URL: #{$driver.current_url} (43)"
      end
    end
    puts "Current URL: #{$driver.current_url} (46)"
    # Not the login page
    if $driver.find_elements(:link, "Forgot your password?").size < 0
      puts "`Forgot your password?` link isn't present. Go to: #{@base_url}"
      $driver.get(@base_url)
      puts "Current URL: #{$driver.current_url} (51)"
      $wait.until { $driver.find_elements(:link, "Learn more").size > 0 }
      puts "Waited until `Learn more` link was present. Current URL: #{$driver.current_url} (53)"
      puts "Click `Log in`."
      $driver.find_element(:link, "Log in").click
      puts "Current URL: #{$driver.current_url} (56)"
      $wait.until { $driver.find_elements(:link, "Forgot your password?").size > 0 }
      puts "Waited until `Forgot your password?` link was present. Current URL: #{$driver.current_url} (58)"
    end
    puts "Current URL: #{$driver.current_url} (60)"
    # On the login page: /login and need to login:
    if $driver.find_elements(:id, "user_email").size > 0
      puts "`user_email` field is present! Current URL: #{$driver.current_url} (63)"
      $driver.find_element(:id, "user_email").clear
      $driver.find_element(:id, "user_email").send_keys "test@outpostqa.com"
      $driver.find_element(:id, "user_password").clear
      $driver.find_element(:id, "user_password").send_keys "LigReb2013"
      $driver.find_element(:name, "commit").click
    end
  end
  puts "Outside of while loop. Should be on /start page. Current URL: #{$driver.current_url} (71)"
  # kill any flash notifications
  $driver.find_element(:css, '.alert a').click if $driver.find_elements(:id, 'flash-msg').size > 0
end


def sign_into_gmail
  $driver.get "https://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en"
  sleep(1)
  if $driver.find_elements(:link, "test@bertcorp.com").size > 0 || $driver.find_elements(:link, "Sign out").size > 0
    sign_out_of_gmail
  end
  if $driver.find_element(:id, "Email").displayed?
    $driver.find_element(:id, "Email").clear
    $driver.find_element(:id, "Email").send_keys "test@bertcorp.com"
  end
  $driver.find_element(:id, "Passwd").clear
  $driver.find_element(:id, "Passwd").send_keys "LigReb2013"
  $driver.find_element(:id, "signIn").click
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
