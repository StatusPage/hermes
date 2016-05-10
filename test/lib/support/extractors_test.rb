require 'test_helper'

class SomeBasicWrapper
  include Hermes::Extractors
end

describe Hermes::Extractors do
  before do
    # bootstrap up a Mail::Message based on a real mailer and texter
    @mailer_message = SandboxMailer.nba_declaration('New Orleans Pelicans')
    @texter_message = SandboxTexter.nba_declaration('Houston Rockets')

    # some class that we can include the module for
    @wrapper = SomeBasicWrapper.new
  end

  it "extracts html" do
    assert_equal @wrapper.extract_html(@mailer_message), "Hi Mike, just wanted to let you know I'm hoping to be drafted by the <b>New Orleans Pelicans</b>"
  end

  it "extracts text" do
    assert_equal @wrapper.extract_text(@mailer_message), "Hi Mike, just wanted to let you know I'm hoping to be drafted by the *New Orleans Pelicans*"
  end

  describe "extracts hermes providers" do
    describe "singular" do
      it "accepts passing into message" do
        message = SandboxMailer.nba_declaration_with_filter('New Orleans Pelicans', Hermes::TwilioProvider)
        assert_equal [Hermes::TwilioProvider], @wrapper.extract_hermes_providers(message)

        message = SandboxMailer.nba_declaration_with_filter('New Orleans Pelicans', [Hermes::TwilioProvider, Hermes::PlivoProvider])
        assert_equal [Hermes::TwilioProvider, Hermes::PlivoProvider], @wrapper.extract_hermes_providers(message)
      end

      it "accepts passing in via methods" do
        @mailer_message.hermes_provider = Hermes::TwilioProvider
        assert_equal [Hermes::TwilioProvider], @wrapper.extract_hermes_providers(@mailer_message)

        @mailer_message.hermes_provider = nil
        @mailer_message.hermes_provider = [Hermes::TwilioProvider, Hermes::PlivoProvider]
        assert_equal [Hermes::TwilioProvider, Hermes::PlivoProvider], @wrapper.extract_hermes_providers(@mailer_message)
      end
    end

    describe "plural" do
      it "accepts passing into message" do
        message = SandboxMailer.nba_declaration_with_filters('New Orleans Pelicans', Hermes::TwilioProvider)
        assert_equal [Hermes::TwilioProvider], @wrapper.extract_hermes_providers(message)

        message = SandboxMailer.nba_declaration_with_filters('New Orleans Pelicans', [Hermes::TwilioProvider, Hermes::PlivoProvider])
        assert_equal [Hermes::TwilioProvider, Hermes::PlivoProvider], @wrapper.extract_hermes_providers(message)
      end

      it "accepts passing in via methods" do
        @mailer_message.hermes_providers = Hermes::TwilioProvider
        assert_equal [Hermes::TwilioProvider], @wrapper.extract_hermes_providers(@mailer_message)

        @mailer_message.hermes_providers = nil
        @mailer_message.hermes_providers = [Hermes::TwilioProvider, Hermes::PlivoProvider]
        assert_equal [Hermes::TwilioProvider, Hermes::PlivoProvider], @wrapper.extract_hermes_providers(@mailer_message)
      end
    end
  end

  describe "extracts from" do
    it "handles emails, which have multiple parts" do
      assert_equal @wrapper.extract_from(@mailer_message, format: :full), 'Tyus Jones <tyus@duke.edu>'
      assert_equal @wrapper.extract_from(@mailer_message, format: :name), 'Tyus Jones'
      assert_equal @wrapper.extract_from(@mailer_message, format: :address), 'tyus@duke.edu'
    end

    it "handles b64y objects, which dont have multiple parts" do
      from = Hermes::Phone.new('us', '9198956637')

      assert_equal @wrapper.extract_from(@texter_message, format: :full), from
      assert_equal @wrapper.extract_from(@texter_message, format: :name), from
      assert_equal @wrapper.extract_from(@texter_message, format: :address), from
    end

    it "handles short codes" do
      from = Hermes::Phone.new("us", "12345")
      from.full_number.must_equal "12345"
      from.short_code?.must_equal true

      from = Hermes::Phone.new("af", "12345")
      from.full_number.must_equal("+9312345")
      from.short_code?.must_equal false
    end

    it "handles a source and a special naming convention using [] and []=" do
      plivo_from = Hermes::Phone.new('us', '9193245341')
      twilio_from = Hermes::Phone.new('us', '9196022733')

      @texter_message[:plivo_from] = Hermes::B64Y.encode(plivo_from)
      @texter_message[:twilio_from] = Hermes::B64Y.encode(twilio_from)

      assert_equal @wrapper.extract_from(@texter_message, source: :plivo), plivo_from
      assert_equal @wrapper.extract_from(@texter_message, source: :twilio), twilio_from
    end

    it "handles a source and a special naming convention using attr_accessor" do
      plivo_from = Hermes::Phone.new('us', '9193245341')
      twilio_from = Hermes::Phone.new('us', '9196022733')

      @texter_message.plivo_from = Hermes::B64Y.encode(plivo_from)
      @texter_message.twilio_from = Hermes::B64Y.encode(twilio_from)

      assert_equal @wrapper.extract_from(@texter_message, source: :plivo), plivo_from
      assert_equal @wrapper.extract_from(@texter_message, source: :twilio), twilio_from
    end
  end

  describe "extracts to" do
    it "handles emails, which have multiple parts" do
      assert_equal @wrapper.extract_to(@mailer_message, format: :full), 'Mike Krzyzewski <satan@duke.edu>'
      assert_equal @wrapper.extract_to(@mailer_message, format: :name), 'Mike Krzyzewski'
      assert_equal @wrapper.extract_to(@mailer_message, format: :address), 'satan@duke.edu'
    end

    it "handles b64y objects, which dont have multiple parts" do
      to = Hermes::Phone.new('us', '9196453565')

      assert_equal @wrapper.extract_to(@texter_message, format: :full), to
      assert_equal @wrapper.extract_to(@texter_message, format: :name), to
      assert_equal @wrapper.extract_to(@texter_message, format: :address), to
    end
  end

  it "lets you know if an extraction is b64y or normal string" do
    email = 'satan@duke.edu'
    phone = Hermes::Phone.new("us", "8007779898")
    phone_encoded = Hermes::B64Y.encode(phone)

    assert_equal @wrapper.complex_extract(email), {decoded: false, value: email}
    assert_equal @wrapper.complex_extract(phone_encoded), {decoded: true, value: phone}
  end
end
