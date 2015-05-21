module Hermes
  class NexmoProvider < Provider
    required_credentials :api_key, :api_secret

    def send_message(rails_message)
      return rails_message
    end

    def payload(rails_message)
      {}
    end

    def client
      
    end
  end
end