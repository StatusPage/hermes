module Hermes
  class TwitterProvider < Provider
    required_credentials :consumer_key, :consumer_secret
    
    def send_message(rails_message)
      self.client(rails_message).update(extract_text(rails_message))
    end

    def client(rails_message)
      to = extract_to(rails_message)

      Twitter::Client.new(
        consumer_key: self.credentials[:consumer_key],
        consumer_secret: self.credentials[:consumer_secret],
        oauth_token: to[:twitter_oauth_token],
        oauth_token_secret: to[:twitter_oauth_token_secret]
      )
    end
  end
end