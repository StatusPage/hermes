class SandboxTexter < ActionMailer::Base
  default from: Hermes::B64Y.encode(Hermes::Phone.new('us', '9198956637'))

  def nba_declaration(team_hopeful)
    @team_hopeful = team_hopeful

    mail to: Hermes::B64Y.encode(Hermes::Phone.new('us', '9196453565')), subject: 'doesnt matter this is a text message'
  end
end