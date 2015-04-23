module Hermes
  class Provider
    include Extractors 

    class << self
      attr_accessor :_required_credentials

      def required_credentials(*args)
        self._required_credentials = args.to_a
      end
    end

    attr_reader :deliverer, :defaults, :credentials, :weight

    def initialize(deliverer, options = {})
      
      options.symbolize_keys!

      @deliverer = deliverer
      @defaults = options[:defaults]
      @credentials = (options[:credentials] || {}).symbolize_keys
      @weight = options[:weight].to_i

      if self.class._required_credentials.try(:any?)
        # provider defines required credentials, let's make sure to check we have everything we need
        if !((@credentials.keys & self.class._required_credentials) == self.class._required_credentials)
          # we're missing something, raise here for hard failure
          raise(InsufficientCredentialsError, "Credentials passed:#{@credentials.keys} do not satisfy all required:#{self.class._required_credentials}")
        end
      end

      unless @weight >= 0
        # provider weights need to be 0 (disabled), or greater than 0 to show as active
        raise(InvalidWeightError, "Provider name:#{common_name} has invalid weight:#{@weight}")
      end
    end

    def common_name
      self.class.name.demodulize.underscore.gsub('_provider', '')
    end

    def send_message(rails_message)
      raise ProviderInterfaceError.new("this is an abstract method and must be defined in the subclass")
    end
  end
end