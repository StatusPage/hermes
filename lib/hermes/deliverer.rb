module Hermes
  class Deliverer
    include Extractors

    attr_reader :providers, :settings

    def initialize(settings)
      # Utils.log_and_puts "XXXXX"
      # Utils.log_and_puts settings
      # Utils.log_and_puts "XXXXX"

      @providers = {}
      
      @settings = settings
      
      # loop through each and construct a workable array
      # provider_types will most likely come back as [:email, :sms, :tweet, :webhook]
      provider_types.each do |provider_type|
        @providers[provider_type] ||= []
        providers = settings[provider_type]
        next unless providers.try(:any?)

        # go through all of the providers and initialize each
        providers.each do |provider_name, options|
          # grab the class based on the generic name
          klass = provider_class_for_name(provider_name)

          # initialize the provider with the given weight, defaults, and credentials
          provider = klass.new(self, options)

          # and add it to the list of providers that we're constructing
          @providers[provider_type] << provider
        end

        # make sure the provider type has an aggregate weight of more than 1
        aweight = aggregate_weight_for_type(provider_type)
        unless aweight > 0
          raise(InvalidWeightError, "Provider type:#{provider_type} has aggregate weight:#{aweight}")
        end
      end
    end

    def provider_types
      @settings.keys.reject{|key| key == :config}
    end

    def provider_class_for_name(provider_name)
      # check to see that the provider class exists
      provider_proper_name = "#{provider_name}_provider".camelize.to_sym
      raise(ProviderNotFoundError, "Could not find provider class Hermes::#{provider_proper_name}") unless Hermes.constants.include?(provider_proper_name)

      # grab the constant and return it
      Hermes.const_get(provider_proper_name)
    end

    def config
      @settings[:config]
    end

    def stats
      self.config[:stats]
    end

    def test_mode?
      !!self.config[:test]
    end

    def should_deliver?
      !self.test_mode? && ActionMailer::Base.perform_deliveries
    end

    def aggregate_weight_for_type(type)
      providers = @providers[type]
      raise ProviderTypeNotFoundError, "Unknown provider type (#{type})" if providers.nil?

      providers.map(&:weight).inject(0, :+)
    end

    def weighted_provider_for_type(type)
      providers = @providers[type]
      unless providers && providers.any?
        raise ProviderNotFoundError, "Could not find any providers for type:#{type}"
      end

      # get the aggregate weight, and do a rand based on it
      random_index = rand(aggregate_weight_for_type(type))

      # loop through each, exclusive range, and find the one that it falls on
      running_total = 0
      providers.each do |provider|
        left_index = running_total
        right_index = running_total + provider.weight

        if (left_index...right_index).include?(random_index)
          return provider
        else
          running_total += provider.weight
        end
      end
    end

    def delivery_type_for(rails_message)
      to = extract_to(rails_message, format: :address)

      self.config[:mappings].each do |delivery_type, classes|
        # mappings can specify multiple classes that will match
        # if it's not an array, it's a single class, put into an array
        classes = [classes] unless classes.is_a?(Array)

        # then loop through all the options
        classes.each do |klass|
          return delivery_type if to.instance_of?(klass)
        end
      end

      # if we got here, nothing matched in the mappings table
      raise UnknownDeliveryTypeError, "Cannot determine provider type from provided to:#{to} class:#{to.class}"
    end

    def deliver!(rails_message)
      # figure out what we're delivering
      delivery_type = delivery_type_for(rails_message)

      # set this on the message so it's available throughout
      rails_message.hermes_type = delivery_type

      # find a provider, weight matters here
      provider = weighted_provider_for_type(delivery_type)

      # and then send the message with some timing info
      t = Time.now
      begin
        # every provider will define this method
        provider.send_message(rails_message)

        # add this to the deliveries array if we're in test mode
        # message will have been modified in place by the provider if necessary (ex. message_id)
        ActionMailer::Base.deliveries << rails_message if self.test_mode?

        # and track the success
        self.track_success(provider, timing_float(t))
      rescue Exception => e
        # track the failure, and then we want to raise the exception again
        # so that it will eventually get retried
        self.track_failure(provider, timing_float(t))
        raise e
      ensure
        # in the very least, track an attempt with some timing
        self.track_attempt(provider, timing_float(t))
      end
    end

    # methods for
    # => track_success
    # => track_failure
    # => track_attempt
    [:success, :failure, :attempt].each do |mname|
      define_method "track_#{mname}" do |provider, timing|
        if self.stats && self.stats.respond_to?(mname)
          self.stats.send(mname, provider, timing)
        end
      end
    end

    def timing_float(start)
      (Time.now - start).to_f
    end
  end
end

ActionMailer::Base.add_delivery_method :hermes, Hermes::Deliverer
