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