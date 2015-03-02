module Hermes
  class SendgridProvider < Provider
    required_credentials :api_user, :api_key
    
    def send_message(rails_message)
      result = client.send(sendgrid_message(rails_message))
      byebug
      puts result
    end

    def sendgrid_message(rails_message)
      # requireds
      message = SendGrid::Mail.new({
        from: rails_message[:from].address_list.addresses.first.address,
        from_name: rails_message[:from].address_list.addresses.first.name,
        to: rails_message[:to].formatted,
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