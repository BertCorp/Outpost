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
  sleep(1)
  while $driver.find_element(:id, "saving_indicator").text != "SAVED" do
    begin
      edit_menu = $driver.find_element(:id, "edit_menu")
      $driver.action.move_to(edit_menu).perform
      edit_menu.click unless $driver.find_element(:id, "mark_draft_button").displayed?
      $driver.find_element(:id, "mark_draft_button").click
    rescue
    end
  end
end

def start_logged_in
  $driver.get(@base_url + 'documents')
  # close any alerts, if they are present
  #if alert_present?
  #  $driver.switch_to.alert.accept
  #end  
  # login, if we aren't already
  if $driver.current_url.include? "draft/users/sign_in"
    $driver.find_element(:id, "draft_user_email").send_keys "test+draft@bertcorp.com"
    $driver.find_element(:id, "draft_user_password").send_keys "changeme"
    $driver.find_element(:name, "commit").click
  end
end

def ensure_user_logs_out
  while $driver.find_elements(:link, "LOGOUT").size > 0 do
    $driver.find_element(:link, "LOGOUT").click
  end
  close_alert_and_get_its_text(true) if alert_present?
  
  sleep(1)
  $driver.find_element(:css, "#homepage_titles > h1").text.should == "WRITE BETTER WITH DRAFT"
  #puts "After logout: #{$driver.current_url}"
end
