module Mail
  class Message
    # a type will be set on the message so we can track it all the way through
    attr_accessor :hermes_type

    # allow users to specify a specific provider or providers they want to send from
    attr_accessor :hermes_provider
    attr_accessor :hermes_providers
  end
end