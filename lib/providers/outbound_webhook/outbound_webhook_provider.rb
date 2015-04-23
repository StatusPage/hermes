module Hermes
  class OutboundWebhookProvider < Provider

    def send_message(rails_message)
      payload = payload(rails_message)
      outbound_webhook = OutboundWebhook.create!(payload)
      rails_message[:message_id] = outbound_webhook.id

      if self.deliverer.should_deliver?
        outbound_webhook.deliver_async
      end
    end

    def payload(rails_message)
      {
        :endpoint => extract_to(rails_message).to_s,
        :headers => {
          'Content-Type' => 'application/json'
        },
        :body => extract_text(rails_message)
      }
    end
  end
end