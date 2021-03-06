module Hermes
  class B64Y
    def self.encode(payload)
      Base64.strict_encode64(YAML.dump(payload))
    end

    def self.decode(payload)
      YAML.load(Base64.strict_decode64(payload))
    end

    def self.decodable?(payload)
      # check to make sure when we decode that it's going to look like a YAML object
      Base64.strict_decode64(payload)[0..2] == '---'
    rescue
      false
    end
  end
end