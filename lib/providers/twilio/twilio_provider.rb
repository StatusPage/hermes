module Hermes
  class TwilioProvider < Provider
    required_credentials :account_sid, :auth_token

    def send_message(rails_message)
      payload = payload(rails_message)

      if self.deliverer.should_deliver?
        result = self.client.account.messages.create(payload)

        # set the sid onto the rails message as the message id, used for tracking
        rails_message[:message_id] = result.sid
      else
        # rails message still needs a fake sid as if it succeeded
        rails_message[:message_id] = SecureRandom.uuid
      end

      return rails_message
    end

    def payload(rails_message)
      # basics for every message
      result = {
        to: extract_to(rails_message).full_number,
        from: extract_from(rails_message, source: :twilio).full_number,
        body: extract_text(rails_message),
      }

      # status callback if they want one
      if status_callback = (extract_custom(rails_message, :twilio_status_callback) || self.default(:status_callback))
        result[:status_callback] = status_callback
      end

      return result
    end

    def client
      Twilio::REST::Client.new(self.credentials[:account_sid], self.credentials[:auth_token])
    end
  end
end