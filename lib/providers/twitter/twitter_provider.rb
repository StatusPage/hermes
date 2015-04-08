module Hermes
  class TwitterProvider < Provider
    required_credentials :consumer_key, :consumer_secret
    
    def send_message(rails_message)
      self.client(rails_message).update(extract_text(rails_message))
    end

    def client(rails_message)
      # this will already be an instance of Twitter::client
      client = extract_to(rails_message)

      # just need to set the consumer key and secret and
      # then we'll be ready for liftoff
      client.consumer_key = self.credentials[:consumer_key]
      client.consumer_secret = self.credentials[:consumer_secret]

      return client
    end
  end
end