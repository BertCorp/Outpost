class ReportMailer < ActionMailer::Base
  default from: "mark@outpostqa.com"
  
  def new_report_email(report)
    @report = report
    @url = report_path(@report)
    
    mail(to: 'marksbertrand@gmail.com', subject: 'A new report has been created')
  end
end
