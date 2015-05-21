module Hermes
  class PlivoProvider < Provider
    required_credentials :auth_id, :auth_token

    def send_message(rails_message)
      payload = payload(rails_message)

      if self.deliverer.should_deliver?
        # sent_message returns the HTTP code and a json payload
        code, body = self.client.send_message(payload)

        # message uuid will be an array, just pull the first item
        rails_message[:message_id] = body["message_uuid"].first
      else
        # rails message still needs a fake sid as if it succeeded
        rails_message[:message_id] = SecureRandom.uuid
      end

      return rails_message
    end

    def payload(rails_message)
      # common for all requests
      result = {
        src:  extract_from(rails_message, source: :plivo).full_number,
        dst:  extract_to(rails_message).full_number,
        text: extract_text(rails_message),
        type: :sms
      }

      # status callback if they want one
      if status_callback = (extract_custom(rails_message, :plivo_status_callback) || self.default(:status_callback))
        result[:url] = status_callback
      end

      return result
    end

    def client
      Plivo::RestAPI.new(self.credentials[:auth_id], self.credentials[:auth_token])
    end
  end
end