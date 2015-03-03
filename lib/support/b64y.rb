module Hermes
  class B64Y
    BASE64_REGEX = /^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$/

    def self.encode(payload)
      Base64.strict_encode64(YAML.dump(payload))
    end

    def self.decode(payload)
      YAML.load(Base64.strict_decode64(payload))
    end

    def self.decodable?(payload)
      payload =~ BASE64_REGEX
    end
  end
end