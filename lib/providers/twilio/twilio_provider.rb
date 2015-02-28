module Hermes
  class TwilioProvider < Provider
    def send_message(rails_message)
      RestClient.post mailgun_url, options
    end

    def mailgun_url
      api_url + "/messages"
    end

    def api_url
      "https://api:#{@credentials.api_key}@api.mailgun.net/v2/#{domain}"
    end
  end
end