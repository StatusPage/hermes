module Hermes
  class PlivoProvider < Provider
    required_credentials :auth_id, :auth_token
    
    def send_message(rails_message)
      payload = payload(rails_message)
      
      if self.deliverer.should_deliver?
        result = self.client.send_message(payload)
        rails_message[:message_id] = result["api_id"]
      else
        # rails message still needs a fake sid as if it succeeded
        rails_message[:message_id] = SecureRandom.uuid
      end
    end

    def payload(rails_message)
      {
        src:  extract_from(rails_message).full_number,
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