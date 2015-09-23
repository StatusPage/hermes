require 'test_helper'

describe Hermes::SparkpostProvider do
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
        sparkpost: {
          credentials: {
            api_key: 'sparkpost_api_key'
          },
          defaults: {
            domain: 'sparkpost_default_domain'
          },
          weight: 1
        },
      }
    }

    @deliverer = Hermes::Deliverer.new(@settings)
  end

  it "doesn't fail to create a sparkpost message" do
    reset_email!
    msg = SandboxMailer.nba_declaration('Houston Rockets')
    @deliverer.deliver!(msg)
    assert_equal 1, email_count
  end
end