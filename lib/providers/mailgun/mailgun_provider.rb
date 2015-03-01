module Hermes
  class MailgunProvider < Provider
    def send_message(rails_message)
      HTTParty.post mailgun_url(rails_message), payload(rails_message)
    end

    def mailgun_url(rails_message)
      "https://api:#{self.credentials[:api_key]}@api.mailgun.net/v2/#{rails_message.mailgun_domain || self.defaults[:domain]}/messages"
    end

    def payload(rails_message)
      # all of the basics required for an email
      payload = {
        from: rails_message[:from].formatted, 
        to: rails_message[:to].formatted, 
        subject: rails_message.subject,
        html: extract_html(rails_message), 
        text: extract_text(rails_message),
      }

      # specific mailgun overrides
      payload['h:Reply-To'] = rails_message.reply_to.formatted.first if rails_message.reply_to
      payload['h:Message-ID'] = rails_message.message_id if rails_message.message_id

      # mailgun variables for replacement
      rails_message.mailgun_variables.try(:each) do |name, value|
        payload["v:#{name}"] = value
      end

      # specific recipient variable replacement
      payload['recipient-variables'] = rails_message.mailgun_recipient_variables.to_json if rails_message.mailgun_recipient_variables

      # any other custom headers
      rails_message.mailgun_headers.try(:each) do |name, value|
        payload["h:#{name}"] = value
      end

      # and mailgun specific options
      rails_message.mailgun_options.try(:each) do |name, value|
        payload["o:#{name}"] = value
      end

      # any attachments?
      payload[:attachment] = []
      payload[:inline] = []
      rails_message.attachments.try(:each) do |attachment|
        if attachment.inline?
          payload[:inline] << MailgunAttachment.new(attachment, encoding: 'ascii-8bit', inline: true)
        else
          payload[:attachment] << MailgunAttachment.new(attachment, encoding: 'ascii-8bit')
        end
      end

      # remove anything that is empty
      payload.delete_if { |key, value| value.nil? }

      return payload
    end

    # @see http://stackoverflow.com/questions/4868205/rails-mail-getting-the-body-as-plain-text
    def extract_html(rails_message)
      if rails_message.html_part
        rails_message.html_part.body.decoded
      else
        rails_message.content_type =~ /text\/html/ ? rails_message.body.decoded : nil
      end
    end

    def extract_text(rails_message)
      if rails_message.multipart?
        rails_message.text_part ? rails_message.text_part.body.decoded : nil
      else
        rails_message.content_type =~ /text\/plain/ ? rails_message.body.decoded : nil
      end
    end
  end
end