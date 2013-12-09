class PagesController < ApplicationController
  
  def index
    render layout: "marketing"
  end
  
  def new_client_confirmation
    render layout: "marketing"
  end

end
