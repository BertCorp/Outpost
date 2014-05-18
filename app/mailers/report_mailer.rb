class ReportMailer < ActionMailer::Base
  default from: "admin@outpostqa.com"
  
  def admin_requested_report_status_email(report, output)
    @report = report
    @output = output
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "#{@report.company.name} report is: #{@report.status}")
  end
  
  def admin_requested_report_triggered_email(report)
    @report = report
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "New report: #{@report.company.name}")
  end
  
  def admin_scheduled_report_status_email(report, output)
    @report = report
    @output = output
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "#{@report.company.name} report (scheduled): #{@report.status}")
  end
  
  def admin_scheduled_report_triggered_email(report)
    @report = report
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "Scheduled report created: #{@report.company.name}")
  end
  
  def admin_triggered_report_email(report)
    @report = report
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "Admin triggered new report for: #{@report.company.name}")
  end
  
  
  def requested_report_under_review_email(report)
    @report = report
    @initiator = @report.initiator
    to_emails = (@initiator.class.eql?(User)) ? @initiator.email : (@initiator.users.collect { |u| u.email }.join(", "))
    
    mail(to: to_emails, subject: "Outpost: Your report is currently UNDER REVIEW (#{Time.now.strftime('%m/%d/%Y')})")
  end
  
  def requested_report_successful_email(report)
    @report = report
    @initiator = @report.initiator
    to_emails = (@initiator.class.eql?(User)) ? @initiator.email : (@initiator.users.collect { |u| u.email }.join(", "))
    
    mail(to: to_emails, subject: "Outpost: Your report has successfully COMPLETED (#{Time.now.strftime('%m/%d/%Y')})")
  end
  
  def requested_report_triggered_email(report)
    @report = report
    @initiator = @report.initiator
    to_emails = (@initiator.class.eql?(User)) ? @initiator.email : (@initiator.users.collect { |u| u.email }.join(", "))
    
    mail(to: to_emails, subject: "Outpost: A new report has been QUEUED (#{Time.now.strftime('%m/%d/%Y')})")
  end

  def scheduled_report_under_review_email(report)
    @report = report
    
    mail(to: "#{@report.company.users.collect { |u| u.email }.join(", ")}", bcc: 'zack@outpostqa.com', subject: "Outpost Test Results: #{@report.status} (#{@report.completed_at.strftime('%m/%d/%Y')})", from: 'zack@outpostqa.com')
  end
  
  def scheduled_report_successful_email(report)
    @report = report
    
    mail(to: "#{@report.company.users.collect { |u| u.email }.join(", ")}", bcc: 'zack@outpostqa.com', subject: "Outpost Test Results: #{@report.status} (#{@report.completed_at.strftime('%m/%d/%Y')})", from: 'zack@outpostqa.com')
  end
    
end
