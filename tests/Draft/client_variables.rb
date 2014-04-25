$environments = { production: "https://draftin.com/" }

def go_home_from_document
  begin
    home_button_expander = $driver.find_element(:id, 'home_button')
    $driver.action.move_to(home_button_expander).perform
    wait.until { $driver.find_element(:id, "home_link").displayed? }
    $driver.find_element(:id, "home_link").click
    sleep(3)
  rescue
    $driver.get(@base_url + 'documents/') unless $driver.current_url ==  @base_url + 'documents'
    sleep(1)
  end
end

def save_document
  begin
    edit_menu = $driver.find_element(:id, "edit_menu")
    $driver.action.move_to(edit_menu).perform
    edit_menu.click unless $driver.find_element(:id, "mark_draft_button").displayed?
    sleep(1)
    $driver.find_element(:id, "mark_draft_button").click
  rescue
  end
  sleep(1)
  # Verify
  $driver.find_element(:id, "saving_indicator").text.should == "SAVED"
end

def start_logged_in
  $driver.get(@base_url + 'documents')
  # close any alerts, if they are present
  if alert_present?
    $driver.switch_to.alert.accept
  end
  # login, if we aren't already
  if $driver.current_url.include? "draft/users/sign_in"
    $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
    $driver.find_element(:id, "draft_user_password").send_keys "changeme"
    $driver.find_element(:name, "commit").click
  end
  # close intercom modal, if it exists
  if element_present?(:css, '.ic_close_modal') && $driver.find_element(:css, '.ic_close_modal').displayed?
    $driver.find_element(:css, '.ic_close_modal').click
  end
end
