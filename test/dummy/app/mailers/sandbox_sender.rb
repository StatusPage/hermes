class SandboxSender < ActionMailer::Base
  def variable_to(to)
    @to = to
    
    mail(to: to, from: 'Variable To <variable@to.com>', subject: 'some subject')
  end
end