class TestMailer < ActionMailer::Base
  default from: "mark@outpostqa.com"
  
  def admin_new_test_email(test)
    @test = test
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "#{@test.company.name} has added a new test!")
  end
  
  def admin_test_updated_email(test)
    @test = test
    
    mail(to: 'mark@outpostqa.com, zack@outpostqa.com', subject: "#{@test.company.name} has been updated one of their tests.")
  end
  
end
