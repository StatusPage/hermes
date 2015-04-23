module Hermes
  class SendgridProvider < Provider
    required_credentials :api_user, :api_key
    
    def send_message(rails_message)
      payload = payload(rails_message)

      if self.deliverer.should_deliver?
        client.send(payload)
      end
    end

    def payload(rails_message)
      # requireds
      message = SendGrid::Mail.new({
        from: extract_from(rails_message, :address),
        from_name: extract_from(rails_message, :name),
        to: extract_to(rails_message, :address),
        to_name: extract_to(rails_message, :name),
        subject: rails_message.subject,
        html: extract_html(rails_message),
        text: extract_text(rails_message),
      })

      # optionals
      message.reply_to = rails_message[:reply_to].formatted.first if rails_message[:reply_to]
      message.message_id = rails_message[:message_id].value if rails_message.message_id

      # and any attachments
      rails_message.attachments.try(:each) do |attachment|
        message.add_attachment_file(Hermes::EmailAttachment.new(attachment))
      end

      return message
    end

    def client
      SendGrid::Client.new({
        api_user: self.credentials[:api_user], 
        api_key: self.credentials[:api_key]
      })
    end
  end
end