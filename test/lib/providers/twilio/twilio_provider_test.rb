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
    @provider = Hermes::TwilioProvider.new(@deliverer, @settings[:sms][:twilio])
  end

  it "doesn't fail to create a twilio message" do
    reset_texts!
    msg = SandboxTexter.nba_declaration('Houston Rockets')

    # check to see that each of the major keys have at least something
    [:to, :from, :body].each do |key|
      assert @provider.payload(msg)[key]
    end

    # deliver it
    @deliverer.deliver!(msg)
    assert_equal 1, texts_count
  end

  it "sets url with message variable, then default, but is okay with nothing" do
    # set the default so it's available
    @provider.defaults[:status_callback] = 'a.com'

    # message variable
    msg = SandboxTexter.nba_declaration('Houston Rockets')
    msg[:twilio_status_callback] = 'b.com'
    assert_equal 'b.com', @provider.payload(msg)[:status_callback]

    msg[:twilio_status_callback] = nil
    msg.twilio_status_callback = 'b.com'
    assert_equal 'b.com', @provider.payload(msg)[:status_callback]

    # default
    msg.twilio_status_callback = nil
    assert_equal 'a.com', @provider.payload(msg)[:status_callback]

    # nothing
    @provider.defaults[:status_callback] = nil
    assert_nil @provider.payload(msg)[:status_callback]
  end

  it "prefers the twilio_from field to the from field" do
    msg = SandboxTexter.nba_declaration('Houston Rockets')

    # no twilio_from field specified, so use the normal from
    assert_equal @provider.payload(msg)[:from], "+19198956637"

    # twilio_from field specified, so use that
    msg.twilio_from = Hermes::B64Y.encode(Hermes::Phone.new('us', '9198675309'))
    assert_equal @provider.payload(msg)[:from], "+19198675309"
  end
end