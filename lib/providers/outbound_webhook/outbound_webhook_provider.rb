module Hermes
  class OutboundWebhookProvider < Provider

    def send_message(rails_message)
      payload = payload(rails_message)

      outbound_webhook = OutboundWebhook.create!(payload)
      rails_message[:message_id] = outbound_webhook.id

      if self.deliverer.should_deliver?
        outbound_webhook.deliver_async
      end

      return rails_message
    end

    def payload(rails_message)
      # the extract_to will return a URI object
      # need to call to_s to get into full endpoint form
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