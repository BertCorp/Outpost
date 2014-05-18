class Admin::AdminController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'
  
  # GET /admin/
  def index
    @test_cases = TestCase.where(setup_completed_at: nil)
    @reports = Report.where("(status = 'queued') OR (status = 'Queued')")    
  end
  
  # POST /admin/generate
  def generate_token
    # get type (company or user) + id
    token = nil
    if params[:type] == 'company'
      c = Company.find(params[:id])
      c.authentication_token = nil
      token = c.ensure_authentication_token
      c.save!
    elsif params[:type] == 'user'
      u = User.find(params[:id])
      u.authentication_token = nil
      token = u.ensure_authentication_token
      u.save!
    else
      return redirect_to :back, alert: "No #{params[:type]} found."
    end
    redirect_to :back, notice: "New token generated for #{params[:type]}: #{token}"
  end
  
  # GET /admin/:token
  def login_via_users_token
    if params[:token][0] == 'u'
      user = User.find_by(authentication_token: params[:token].to_s)
      # http://stackoverflow.com/questions/10253366/need-to-return-json-formatted-404-error-in-rails
      return redirect_to root_path, alert: "These are not the droids you are looking for." if !user
      sign_in user
      redirect_to dashboard_path, notice: "Logged in as: #{user.name} from #{user.company.name}"
    else
      redirect_to root_path, alert: "No no no!"
    end
  end

end
