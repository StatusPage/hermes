module Hermes
  class MailgunProvider < Provider
    def send_message(rails_message)
      domain = rails_message.mailgun_domain || self.defaults[:domain]
      message = self.mailgun_message(rails_message)
      self.client.send_message(domain, message)
    end

    def mailgun_message(rails_message)
      message = Mailgun::MessageBuilder.new

      # basics
      message.set_from_address(rails_message[:from].formatted)
      message.add_recipient(:to, rails_message[:to].formatted)
      message.set_subject(rails_message[:subject])
      message.set_html_body(extract_html(rails_message))
      message.set_text_body(extract_text(rails_message))
      message.set_message_id(rails_message.message_id)

      # optionals
      message.set_from_address('h:reply-to', rails_message[:reply_to].formatted.first) if rails_message[:reply_to]

      # and any attachments
      rails_message.attachments.try(:each) do |attachment|
        message.add_attachment(Hermes::EmailAttachment.new(attachment))
      end

      return message
    end

    def client
      Mailgun::Client.new(self.credentials[:api_key])
    end
  end
end