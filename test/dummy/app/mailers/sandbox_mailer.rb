class SandboxMailer < ActionMailer::Base
  default from: 'Tyus Jones <tyus@duke.edu>'

  def nba_declaration(team_hopeful)
    @team_hopeful = team_hopeful
    
    mail to: 'Mike Krzyzewski <satan@duke.edu>', subject: 'leaving for the nba lol, good luck next year'
  end
end