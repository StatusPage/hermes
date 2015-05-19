require 'test_helper'

describe Hermes::PlivoProvider do
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
        plivo: {
          credentials: {
            auth_id: 'plivo_auth_id',
            auth_token: 'plivo_auth_token'
          },
          weight: 1
        },
      }
    }

    @deliverer = Hermes::Deliverer.new(@settings)
    @provider = Hermes::PlivoProvider.new(@deliverer, @settings[:sms][:plivo])
  end

  it "doesn't fail to create a plivo message" do
    reset_texts!
    msg = SandboxTexter.nba_declaration('Houston Rockets')

    # check to see that each fo the major keys have at least something
    [:src, :dst, :text, :type].each do |key|
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
    msg[:plivo_status_callback] = 'b.com'
    assert_equal 'b.com', @provider.payload(msg)[:url]

    msg[:plivo_status_callback] = nil
    msg.plivo_status_callback = 'b.com'
    assert_equal 'b.com', @provider.payload(msg)[:url]

    # default
    msg.plivo_status_callback = nil
    assert_equal 'a.com', @provider.payload(msg)[:url]

    # nothing
    @provider.defaults[:status_callback] = nil
    assert_nil @provider.payload(msg)[:url]
  end

  it "prefers the plivo_from field to the from field" do
    msg = SandboxTexter.nba_declaration('Houston Rockets')

    # no plivo_from field specified, so use the normal from
    assert_equal @provider.payload(msg)[:src], "+19198956637"

    # plivo_from field specified, so use that
    msg.plivo_from = Hermes::B64Y.encode(Hermes::Phone.new('us', '9198675309'))
    assert_equal @provider.payload(msg)[:src], "+19198675309"
  end
end