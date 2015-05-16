require 'test_helper'

describe Hermes::SendgridProvider do
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
        sendgrid: {
          credentials: {
            api_user: 'sendgrid_api_user',
            api_key: 'sendgrid_api_key'
          },
          weight: 1
        },
      }
    }

    @deliverer = Hermes::Deliverer.new(@settings)
  end

  it "doesn't fail to create a sendgrid message" do
    reset_email!
    msg = SandboxMailer.nba_declaration('Houston Rockets')
    @deliverer.deliver!(msg)
    assert_equal 1, email_count
  end
end