class ReportMailer < ActionMailer::Base
  default from: "mark@outpostqa.com"
  
  def admin_new_report_email(report)
    @report = report
    @url = report_path(@report)
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: 'A new report has been created')
  end
  
  def user_new_report_email(report)
    @report = report
    @initiator = @report.initiator
    @url = report_path(@report)
    
    mail(to: @initiator.email, subject: 'A new report has been created')
  end
end
