module Hermes
  class TwilioProvider < Provider
    def send_message(rails_message)
      payload = payload(rails_message)
      self.client.account.messages.create(payload)
    end

    def payload(rails_message)
      {
        to: rails_message[:to],
        from: rails_message[:from],
        body: rails_message.body.decoded.strip,
        status_callback: rails_message.twilio_status_callback
      }
    end

    def client
      Twilio::REST::Client.new(self.credentials[:account_sid], self.credentials[:account_token])
    end
  end
end