module Hermes
  class SendGridProvider < Provider
    def send_message(rails_message)
      RestClient.post mailgun_url, options
    end

    def client
      SendGrid::Client.new({
        api_user: self.credentials[:api_user], 
        api_key: self.credentials[:api_key]
      })
    end
  end
end