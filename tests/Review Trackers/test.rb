require "rubygems"
require "selenium-webdriver"
require "rspec"
require 'rspec/expectations'
require "./tests/test_helper"
require File.dirname(__FILE__) + '/client_variables.rb'

describe "Tests" do

  it "test" do
    begin
      $to_test.each do |test|
        if test[:device]
          puts "** Checking: #{test[:device]} v#{test[:version]} **"
        elsif test[:browser]
          puts "** Checking: #{test[:browser]} @ #{test[:resolution]} **"
        end
        
        $urls.each do |name, info|
          puts ""
          puts "#{name}: #{info.inspect}"
          
          if screenshot_already_exists?(test, name)
            puts "Skipping: Already exists"
          else
            puts take_screenshot(test, name, info)
          end
        end
        puts ""
        if $driver && ($driver != nil)
          $driver.quit
          $driver = nil
        end
      end
    ensure
      if $driver && ($driver != nil)
        $driver.quit
        $driver = nil
      end
    end
  end



=begin

- http://reviewtrackers.com
- https://secure.reviewtrackers.com/users/sign_in
- https://secure.reviewtrackers.com/account_dashboard
	email: '#user_email' => "demo@reviewtrackers.com"
  password: '#user_password' => "trackmyreviews"
  click: 'button'
- https://secure.reviewtrackers.com/request_reviews/new
- https://secure.reviewtrackers.com/settings/15/edit
- https://secure.reviewtrackers.com/reviews/407976

- http://www.reviewtrackers.com/tour/
- http://www.reviewtrackers.com/pricing/
- http://www.reviewtrackers.com/blog/
- http://www.reviewtrackers.com/contact/
- http://www.reviewtrackers.com/91-percent-women-research-online-influenced-reviews-making-purchase/
- http://www.reviewtrackers.com/lp/

["800x600", "1024x768", "1280x1024", "1440x900", "1920x1200"]
["firefox mac", "chrome mac", "safari mac", "ie8", "ie9", "ie10", "ie11", "iphone 5", "ipad 3"]

=end

end
