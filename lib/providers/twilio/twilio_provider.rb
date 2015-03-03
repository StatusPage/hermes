module Hermes
  class TwilioProvider < Provider
    required_credentials :account_sid, :auth_token

    def send_message(rails_message)
      payload = payload(rails_message)
      result = self.client.account.messages.create(payload)

      # set the sid onto the rails message as the message id, used for tracking
      rails_message[:message_id] = result.sid
    end

    def payload(rails_message)
      payload = {
        to: extract_to(rails_message),
        from: extract_from(rails_message),
        body: extract_text(rails_message),
      }

      payload[:status_callback] = rails_message.twilio_status_callback if rails_message.twilio_status_callback

      return payload
    end

    def client
      Twilio::REST::Client.new(self.credentials[:account_sid], self.credentials[:auth_token])
    end
  end
end