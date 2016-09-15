module Hermes
  class Provider
    include Extractors

    class << self
      attr_accessor :_required_credentials, :_provider_specific_data

      def required_credentials(*args)
        self._required_credentials = args.to_a
      end
    end

    attr_reader :deliverer, :defaults, :credentials

    def initialize(deliverer, options = {})

      options.symbolize_keys!

      # keep some things around that we'll need
      @deliverer = deliverer
      @defaults = (options[:defaults] || {}).symbolize_keys
      @credentials = (options[:credentials] || {}).symbolize_keys
      @weight = options[:weight]

      # required credentials should hard stop if they aren't being met
      if self.class._required_credentials.try(:any?)
        # provider defines required credentials, let's make sure to check we have everything we need
        if !((@credentials.keys & self.class._required_credentials) == self.class._required_credentials)
          # we're missing something, raise here for hard failure
          raise(InsufficientCredentialsError, "Credentials passed:#{@credentials.keys} do not satisfy all required:#{self.class._required_credentials}")
        end
      end

      # provider weights need to be 0 (disabled), or greater than 0 to show as active
      unless @weight >= 0
        raise(InvalidWeightError, "Provider name:#{common_name} has invalid weight:#{@weight}")
      end
    end

    def common_name
      self.class.name.demodulize.underscore.gsub('_provider', '')
    end

    def default(key)
      v = self.defaults.fetch(key, nil)
      return unless v

      if v.is_a?(Proc)
        v.call
      else
        v
      end
    end

    def weight
      if @weight.is_a?(Fixnum)
        @weight.to_i
      elsif @weight.is_a?(Class)
        @weight_determiner ||= @weight.new(common_name)
        @weight_determiner.weight
      end
    end

    def send_message(rails_message)
      raise ProviderInterfaceError.new("this is an abstract method and must be defined in the subclass")
    end
  end
end