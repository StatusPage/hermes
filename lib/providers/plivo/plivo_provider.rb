module Hermes
  class PlivoProvider < Provider
    def send_message(rails_message)
      self.client.send_message(payload(rails_message))
    end

    def payload(rails_message)
      {
        src: rails_message[:from].formatted.first,
        dst: rails_message[:to].formatted.first,
        text: extract_text(rails_message),
        type: :sms,
      }
    end

    def client
      Plivo::RestAPI.new(self.credentials[:auth_id], self.credentials[:auth_token])
    end
  end
end