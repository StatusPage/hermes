module Hermes
  class SendGridProvider < EmailProvider
    def send_message(rails_message)
      client.send(sendgrid_message(rails_message))
    end

    def sendgrid_message(rails_message)
      message = SendGrid::Mail.new({
        to: 'example@example.com', 
        from: 'taco@cat.limo', 
        subject: 'Hello world!', 
        text: 'Hi there!', 
        html: '<b>Hi there!</b>'
      })
    end

    def client
      SendGrid::Client.new({
        api_user: self.credentials[:api_user], 
        api_key: self.credentials[:api_key]
      })
    end
  end
end