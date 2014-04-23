require 'rake'

Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
Outpost::Application.load_tasks # providing your application name is 'sample'

class PagesController < ApplicationController
  
  def index
    render layout: "marketing"
  end
  
  def new_client_confirmation
    render layout: "marketing"
  end
  
  def test
    #output = %x{ bundle exec rspec './tests/Test Client/test_suite.rb' }
    #output.chomp!
    #output = output.split("\n")
    #logger.info output.inspect
    #render text: output
    #Rake::Task['test:test_1'].reenable # in case you're going to invoke the same task second time.
    output = Rake::Task['test:test_1'].invoke(1)

    render text: output
  end

end
