module Hermes
  class TwilioProvider < Provider
    def send_message(rails_message)
      payload = payload(rails_message)
      result = self.client.account.messages.create(payload)

      # set the sid onto the rails message as the message id, used for tracking
      rails_message[:message_id] = result.sid
    end

    def payload(rails_message)
      {
        to: rails_message[:to],
        from: rails_message[:from],
        body: extract_text(rails_message),
        status_callback: rails_message.twilio_status_callback
      }
    end

    def client
      Twilio::REST::Client.new(self.credentials[:account_sid], self.credentials[:account_token])
    end
  end
end