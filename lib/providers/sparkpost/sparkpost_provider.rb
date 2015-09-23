module Hermes
  class SparkpostProvider < Provider
    required_credentials :api_key

    def send_message(rails_message)
      domain = extract_custom(rails_message, :sparkpost_domain)
      domain = self.defaults[:domain] if domain.blank?
      
      message = self.sparkpost_message(rails_message)

      if self.deliverer.should_deliver?
        response = RestClient.post(
          "https://api.sparkpost.com/api/v1/transmissions", 
          message.to_json, 
          headers
        )

        # a transmission id will come through, we should store that
        parsed_response = JSON.parse(response)
        rails_message[:message_id] = parsed_response["results"]["id"]
      else
        # rails message still needs a fake number
        rails_message[:message_id] = SecureRandom.uuid
      end

      return rails_message
    end

    def sparkpost_headers
      {
        authorization: self.credentials[:api_key],
        content_type: "application/json"
      }
    end

    def sparkpost_message(rails_message)
      # start off with the basics
      message = {
        options: {
          transactional: true
        }
      }

      # the recipients, always an array
      message[:recipients] = [
        {
          address: {
            email: extract_to(rails_message, format: :address),
            name: extract_to(rails_message, format: :name)
          }
        }
      ]

      # and the content
      message[:content] = {
        from: {
          email: extract_from(rails_message, format: :address),
          name: extract_from(rails_message, format: :name)
        },
        subject: "this is a test email from sparkpost",
        text: "New incident has been reported!",
        html: "<b>Investigating!</b><p>New incident has been reported!</p>"
      }

      # reply-to is optional
      message[:content][:reply_to] = rails_message[:reply_to].formatted.first if rails_message[:reply_to]

      # attachments are a no-op for now while they're not supported
      # stub it out here anyway
      rails_message.attachments.try(:each) do |attachment|
        # no-op
        # message.add_attachment(Hermes::EmailAttachment.new(attachment))
      end
      
      return message
    end
  end
end