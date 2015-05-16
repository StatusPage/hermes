require 'test_helper'

describe Hermes::TwilioProvider do
  before do
    @settings = {
      config: {
        test: true,
        mappings: {
          sms: Hermes::Phone
        },
        stats: Hermes::CompleteStatsHandler
      },
      sms: {
        twilio: {
          credentials: {
            account_sid: 'twilio_account_sid',
            auth_token: 'twilio_auth_token'
          },
          weight: 1
        },
      }
    }

    @deliverer = Hermes::Deliverer.new(@settings)
  end

  it "doesn't fail to create a twilio message" do
    reset_email!
    msg = SandboxTexter.nba_declaration('Houston Rockets')
    @deliverer.deliver!(msg)
    assert_equal 1, texts_count
  end
end