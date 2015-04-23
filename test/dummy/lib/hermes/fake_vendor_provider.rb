module Hermes
  class FakeVendorProvider < Provider
    required_credentials :api_key, :api_token
    
    def send_message(rails_message)
      # no-op
    end
  end
end