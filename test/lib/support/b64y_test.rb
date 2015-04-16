require 'test_helper'

describe Hermes::B64Y do
  it "uses strict base64, no line breaks" do
    # generate a bunch of random data
    data = SecureRandom.hex(4096)

    # make sure we have line breaks with no strict
    assert Base64.encode64(data).include?("\n")

    # and b64y wont have line breaks
    refute Hermes::B64Y.encode(data).include?("\n")
  end

  it "has a horribly inefficient sanity check for decodability" do
    basic = Base64.strict_encode64("hello")
    yaml = Base64.strict_encode64(Time.to_yaml)
    
    refute Hermes::B64Y.decodable?(basic)
    assert Hermes::B64Y.decodable?(yaml)
  end
end