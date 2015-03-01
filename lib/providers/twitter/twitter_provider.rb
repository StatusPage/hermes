module Hermes
  class TwitterProvider < Provider
    def send_message(rails_message)
      client.update(rails_message.body.decoded.strip)
    end

    def client(rails_message)
      Twitter::Client.new(
        consumer_key: self.credentials[:consumer_key],
        consumer_secret: self.credentials[:consumer_secret],
        oauth_token: rails_message.twitter_oauth_token || self.credentails[:twitter_oauth_token],
        oauth_token_secret: rails_message.twitter_oauth_token_secret || self.credentails[:twitter_oauth_token_secret]
      )
    end
  end
end