module Hermes
  class PlivoProvider < Provider
    required_credentials :auth_id, :auth_token
    
    def send_message(rails_message)
      result = self.client.send_message(payload(rails_message))
      rails_message[:message_id] = result["api_id"]
    end

    def payload(rails_message)
      {
        src:  extract_from(rails_message),
        dst:  extract_to(rails_message),
        text: extract_text(rails_message),
        type: :sms,
        url:  rails_message.plivo_url || self.defaults[:url]
      }
    end

    def client
      Plivo::RestAPI.new(self.credentials[:auth_id], self.credentials[:auth_token])
    end
  end
end