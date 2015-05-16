require 'test_helper'

describe Hermes::MailgunProvider do
  before do
    @settings = {
      config: {
        test: true,
        mappings: {
          email: String
        },
        stats: Hermes::CompleteStatsHandler
      },
      email: {
        mailgun: {
          credentials: {
            api_key: 'mailgun_api_key'
          },
          defaults: {
            domain: 'mailgun_default_domain'
          },
          weight: 1
        },
      }
    }

    @deliverer = Hermes::Deliverer.new(@settings)
  end

  it "doesn't fail to create a mailgun message" do
    reset_email!
    msg = SandboxMailer.nba_declaration('Houston Rockets')
    @deliverer.deliver!(msg)
    assert_equal 1, email_count
  end
end