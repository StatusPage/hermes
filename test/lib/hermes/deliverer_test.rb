require 'test_helper'

describe Hermes::Deliverer do
  before do
    @settings = {
      config: {
        test: true,
        mappings: {
          email: String,
          sms: [Hermes::Phone, Hermes::Beeper]
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
      },
      sms: {
        twilio: {
          credentials: {
            account_sid: 'twilio_account_sid',
            auth_token: 'twilio_auth_token'
          },
          weight: 6
        },
        plivo: {
          credentials: {
            auth_id: 'plivo_auth_id',
            auth_token: 'plivo_auth_token'
          },
          weight: 1
        },
        nexmo: {
          credentials: {
            api_key: 'nexmo_api_key',
            api_secret: 'nexmo_api_secret'
          },
          weight: 1
        }
      },
    }
  end

  describe :basics do
    it "detects provider types based on the settings hash, ignores :config key" do
      assert_equal Hermes::Deliverer.new(@settings).provider_types, [:email, :sms]
    end

    it "grabs an actual provider class based on a common string name" do
      deliverer = Hermes::Deliverer.new(@settings)
      
      # successes
      assert_equal deliverer.provider_class_for_name("twilio"), Hermes::TwilioProvider
      assert_equal deliverer.provider_class_for_name("mailgun"), Hermes::MailgunProvider

      # cant find
      assert_raises(Hermes::ProviderNotFoundError, "Could not find provider class Hermes::AsdfProvider") do
        deliverer.provider_class_for_name("asdf")
      end
    end

    it "uses truthiness to detect test mode" do
      @settings[:config][:test] = true
      assert Hermes::Deliverer.new(@settings).test_mode?

      @settings[:config][:test] = 'false'
      assert Hermes::Deliverer.new(@settings).test_mode?

      @settings[:config][:test] = false
      refute Hermes::Deliverer.new(@settings).test_mode?

      @settings[:config][:test] = nil
      refute Hermes::Deliverer.new(@settings).test_mode?
    end

    it "respects perform_deliveries and test_mode for actual deliveries" do
      # live mode, no deliveries
      @settings[:config][:test] = false
      ActionMailer::Base.perform_deliveries = false
      refute Hermes::Deliverer.new(@settings).should_deliver?

      # live mode, deliveries
      @settings[:config][:test] = false
      ActionMailer::Base.perform_deliveries = true
      assert Hermes::Deliverer.new(@settings).should_deliver?

      # test mode, no deliveries
      @settings[:config][:test] = true
      ActionMailer::Base.perform_deliveries = false
      refute Hermes::Deliverer.new(@settings).should_deliver?

      # test mode, deliveries
      @settings[:config][:test] = true
      ActionMailer::Base.perform_deliveries = true
      refute Hermes::Deliverer.new(@settings).should_deliver?
    end

    it "calculates an aggregate weight for a message type" do
      deliverer = Hermes::Deliverer.new(@settings)

      # successfully found
      assert_equal 1, deliverer.aggregate_weight_for_type(:email)
      assert_equal 8, deliverer.aggregate_weight_for_type(:sms)

      # cannot find
      assert_raises(Hermes::ProviderTypeNotFoundError, "Unknown provider type (asdf)") do
        deliverer.aggregate_weight_for_type(:asdf)
      end
    end

    describe "does a weighted selection of a provider" do
      it "can accept no filters" do
        # use sms here, run 1000 selections and check the results
        # we should be +/- some threshold of values
        # twilio should end up roughly 75% of the selections
        deliverer = Hermes::Deliverer.new(@settings)
        variation_threshold = 40

        # keep track of the results as we go along, then we'll check the counts later
        results = {
          Hermes::TwilioProvider => 0,
          Hermes::PlivoProvider => 0,
          Hermes::NexmoProvider => 0
        }

        1000.times do
          provider = deliverer.weighted_provider_for_type(:sms)
          results[provider.class] += 1
        end

        assert_in_delta results[Hermes::TwilioProvider], 750, variation_threshold, "Variation threshold:#{variation_threshold} may be too low. Consider adjusting."
        assert_in_delta results[Hermes::PlivoProvider], 125, variation_threshold, "Variation threshold:#{variation_threshold} may be too low. Consider adjusting."
        assert_in_delta results[Hermes::NexmoProvider], 125, variation_threshold, "Variation threshold:#{variation_threshold} may be too low. Consider adjusting."
      end

      it "can accept filters" do
        # filter on just plivo and nexmo here, we should see roughly 50/50
        deliverer = Hermes::Deliverer.new(@settings)
        variation_threshold = 30

        # keep track of the results as we go along, then we'll check the counts later
        results = {
          Hermes::TwilioProvider => 0,
          Hermes::PlivoProvider => 0,
          Hermes::NexmoProvider => 0
        }

        1000.times do
          provider = deliverer.weighted_provider_for_type(:sms, filter: [Hermes::PlivoProvider, Hermes::NexmoProvider])
          results[provider.class] += 1
        end

        assert_equal results[Hermes::TwilioProvider], 0
        assert_in_delta results[Hermes::PlivoProvider], 500, variation_threshold, "Variation threshold:#{variation_threshold} may be too low. Consider adjusting."
        assert_in_delta results[Hermes::NexmoProvider], 500, variation_threshold, "Variation threshold:#{variation_threshold} may be too low. Consider adjusting."
      end
    end

    it "detects a delivery type for a rails message based on the to field and the mappings array" do
      email = 'Scott Klein <scott@example.com>'
      phone = Hermes::B64Y.encode(Hermes::Phone.new('us', '9198675309'))
      beeper = Hermes::B64Y.encode(Hermes::Beeper.new('us', '9195551234'))
      twitter = Hermes::B64Y.encode(Twitter::Client.new)

      deliverer = Hermes::Deliverer.new(@settings)

      # email
      message = SandboxSender.variable_to(email)
      assert_equal :email, deliverer.delivery_type_for(message)

      # phone and beeper should be the same, detected as sms
      message = SandboxSender.variable_to(phone)
      assert_equal :sms, deliverer.delivery_type_for(message)

      message = SandboxSender.variable_to(beeper)
      assert_equal :sms, deliverer.delivery_type_for(message)

      # twitter we don't have anything for, should raise
      message = SandboxSender.variable_to(twitter)
      assert_raises Hermes::UnknownDeliveryTypeError do
        deliverer.delivery_type_for(message)
      end
    end
  end

  describe :deliver! do
    before do
      ActionMailer::Base.deliveries.clear
      @message = SandboxMailer.nba_declaration('asdf')
    end

    it "sets a hermes type on the message" do
      deliverer = Hermes::Deliverer.new(@settings)
      assert_nil @message.hermes_type

      deliverer.deliver!(@message)
      assert_equal :email, @message.hermes_type
    end

    it "adds to the deliveries array if we're in test mode" do
      # test mode
      assert_empty ActionMailer::Base.deliveries
      deliverer = Hermes::Deliverer.new(@settings)
      deliverer.deliver!(@message)
      refute_empty ActionMailer::Base.deliveries

      # live mode, but disable deliveries
      ActionMailer::Base.deliveries.clear
      ActionMailer::Base.perform_deliveries = false
      @settings[:config][:test] = false
      deliverer = Hermes::Deliverer.new(@settings)

      assert_empty ActionMailer::Base.deliveries
      deliverer.deliver!(@message)
      assert_empty ActionMailer::Base.deliveries
    end

    it "detects a provider filter being passed in" do

    end
  end

  describe :tracking do
    before do
      @message = SandboxMailer.nba_declaration('asdf')
    end

    describe Hermes::CompleteStatsHandler do
      before do
        @deliverer = Hermes::Deliverer.new(@settings)
      end

      it "tracks attempt and success on success" do
        Hermes::CompleteStatsHandler.expects(:success).once
        Hermes::CompleteStatsHandler.expects(:attempt).once
        Hermes::CompleteStatsHandler.expects(:failure).never
        @deliverer.deliver!(@message)
      end

      it "tracks attempt and failure on failure" do
        Hermes::MailgunProvider.any_instance.expects(:send_message).raises(StandardError)
        Hermes::CompleteStatsHandler.expects(:success).never
        Hermes::CompleteStatsHandler.expects(:attempt).once
        Hermes::CompleteStatsHandler.expects(:failure).once

        # catch the exception so the test doesn't fail
        @deliverer.deliver!(@message) rescue nil
      end
    end

    describe Hermes::SelectiveStatsHandler do
      before do
        # this class only defines :attempt
        # just run things and make sure the tests dont blow up
        # our logic uses :respond_to?, and setting expectations with :expects
        # changes the object and what it will respond to
        @settings[:config][:stats] = Hermes::SelectiveStatsHandler
        @deliverer = Hermes::Deliverer.new(@settings)
      end

      it "tracks attempt and nothing else on success" do
        @deliverer.deliver!(@message)
      end

      it "tracks attempt and nothing else on failure" do
        Hermes::MailgunProvider.any_instance.expects(:send_message).raises(StandardError)
        
        # catch the exception so the test doesn't fail
        @deliverer.deliver!(@message) rescue nil
      end
    end

    describe :no_stats_handler do
      before do
        # same as above, just run things and make sure the tests
        # dont fail when we have no stats handler defined
        @settings[:config][:stats] = nil
        @deliverer = Hermes::Deliverer.new(@settings)
      end

      it "tracks nothing on success" do
        @deliverer.deliver!(@message)
      end

      it "tracks nothing on failure" do
        Hermes::MailgunProvider.any_instance.expects(:send_message).raises(StandardError)
        
        # catch the exception so the test doesn't fail
        @deliverer.deliver!(@message) rescue nil
      end
    end
  end
end