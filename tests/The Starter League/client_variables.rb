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
  $driver.get(@base_url) unless $driver.current_url == @base_url
  $driver.find_element(:link, "Log in").click
  
  return true if $driver.find_elements(:link, 'test@outpostqa.com').size > 0
  
  if $driver.find_elements(:link, "Logout").size > 0
    $driver.find_element(:link, "Logout").click
    $wait.until { $driver.find_elements(:link, "Learn more").size > 0 }
  end
  
  if $driver.find_elements(:link, "Forgot your password?").size < 0
    $driver.get(@base_url + 'login')
    $wait.until { $driver.find_elements(:link, "Forgot your password?").size > 0 }
  end
  
  if $driver.find_elements(:id, "user_email").size < 0
    $driver.get(@base_url + 'login')
    $wait.until { $driver.find_elements(:id, "user_email").size > 0 }    
  end
  
  $driver.find_element(:id, "user_email").clear
  $driver.find_element(:id, "user_email").send_keys "test@outpostqa.com"
  $driver.find_element(:id, "user_password").clear
  $driver.find_element(:id, "user_password").send_keys "LigReb2013"
  $driver.find_element(:name, "commit").click
  $wait.until { $driver.find_elements(:link, 'test@outpostqa.com').size > 0 }
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
