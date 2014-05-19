class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def dashboard    
    @report = Report.new
    @reports = current_user.company.reports.find(:all, :order => "id desc", :limit => 5)
  end
  
  # GET /tools
  def tools
    unless current_user.authentication_token.present?
      u = current_user
      u.ensure_authentication_token
      u.save!
    end
  end

end
