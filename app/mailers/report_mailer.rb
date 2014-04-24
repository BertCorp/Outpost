class ReportMailer < ActionMailer::Base
  default from: "admin@outpostqa.com"
  
  def admin_triggered_report_email(report)
    @report = report
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "Admin triggered new report for: #{@report.company.name}")
  end
  
  def admin_report_completed_email(report, output)
    @report = report
    @output = output
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "#{@report.company.name} report is: #{@report.status}")
  end
  
  def admin_new_report_email(report)
    @report = report
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "New report: #{@report.company.name}")
  end
  
  def user_new_report_email(report)
    @report = report
    @initiator = @report.initiator
    
    mail(to: @initiator.email, subject: "A new report has been queued.")
  end
  
  def scheduled_report_completed_email(report, output)
    @report = report
    @output = output
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "#{@report.company.name} report (scheduled): #{@report.status}")
  end
  
  def scheduled_report_triggered_email(report)
    @report = report
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "Scheduled report created: #{@report.company.name}")
  end
  
  def successful_report_email(report)
    @report = report
    
    mail(to: @initiator.email, subject: "Your report has successfully completed.")
  end
  
end
