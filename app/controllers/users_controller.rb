class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def dashboard    
    @report = Report.new
    @reports = current_user.company.reports.find(:all, :order => "id desc", :limit => 5)
  end

end
