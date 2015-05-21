class SandboxMailer < ActionMailer::Base
  default from: 'Tyus Jones <tyus@duke.edu>'

  def nba_declaration(team_hopeful)
    @team_hopeful = team_hopeful
    
    mail to: 'Mike Krzyzewski <satan@duke.edu>', subject: 'leaving for the nba lol, good luck next year'
  end

  def nba_declaration_with_filter(team_hopeful, filter)
    @team_hopeful = team_hopeful
    
    # notice the singular here
    mail(hermes_provider: filter, to: 'Mike Krzyzewski <satan@duke.edu>', subject: 'leaving for the nba lol, good luck next year')
  end

  def nba_declaration_with_filters(team_hopeful, filters)
    @team_hopeful = team_hopeful
    
    # notice the plural here
    mail(hermes_providers: filters, to: 'Mike Krzyzewski <satan@duke.edu>', subject: 'leaving for the nba lol, good luck next year')
  end
end