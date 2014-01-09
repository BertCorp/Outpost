class Admin::AdminController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'
  
  # GET /admin/
  def index
    @test_cases = TestCase.where(setup_completed_at: nil)
    @reports = Report.where("(status = 'queued') OR (status = 'Queued')")    
  end

end
