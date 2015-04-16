require 'test_helper'

describe Hermes::EmailAttachment do
  before do
    @rando = SecureRandom.hex
    @attachment = stub(
      cid: @rando, 
      filename: "marleigh.jpg",
      content_type: "image/jpeg; UTF-8",
      body: Mail::Body.new("jake dog")
    )
  end

  it "extracts basic fields" do
    attachment = Hermes::EmailAttachment.new(@attachment)
    assert_equal attachment.content_type, "image/jpeg"
    assert_equal attachment.read, "jake dog"
  end

  it "sets filename for normal attachment" do
    regular = Hermes::EmailAttachment.new(@attachment)
    assert_equal regular.original_filename, "marleigh.jpg"
  end

  it "sets filename for inline attachment" do
    inline = Hermes::EmailAttachment.new(@attachment, inline: true)
    assert_equal inline.original_filename, @rando
  end
end