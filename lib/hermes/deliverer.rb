require 'digest/md5'

module Hermes
  class Deliverer
    include Extractors

    attr_reader :providers, :config

    def initialize(settings)
      # Utils.log_and_puts "XXXXX"
      # Utils.log_and_puts settings
      # Utils.log_and_puts "XXXXX"

      @providers = {}
      
      @config = settings[:config]

      # this will most likely come back as [:email, :sms, :tweet, :webhook]
      provider_types = settings.keys.reject{|key| key == :config}
      
      # loop through each and construct a workable array
      provider_types.each do |provider_type|
        @providers[provider_type] ||= []
        providers = settings[provider_type]
        next unless providers.try(:any?)

        # go through all of the providers and initialize each
        providers.each do |provider_name, options|
          # check to see that the provider class exists
          provider_proper_name = "#{provider_name}_provider".camelize.to_sym
          raise(ProviderNotFoundError, "Could not find provider class Hermes::#{provider_proper_name}") unless Hermes.constants.include?(provider_proper_name)

          # initialize the provider with the given weight, defaults, and credentials
          provider = Hermes.const_get(provider_proper_name).new(self, options)
          @providers[provider_type] << provider
        end

        # make sure the provider type has an aggregate weight of more than 1
        aweight = aggregate_weight_for_type(provider_type)
        unless aweight > 0
          raise(InvalidWeightError, "Provider type:#{provider_type} has aggregate weight:#{aweight}")
        end
      end
    end

    def test_mode?
      !!@config[:test]
    end

    def track_success(provider)
      @config[:stats].try(:success, provider)
    end

    def track_failure(provider)
      @config[:stats].try(:failure, provider)
    end

    def track_attempt(provider, timing)
      @config[:stats].try(:attempt, provider, timing)
    end

    def should_deliver?
      !self.test_mode? && ActionMailer::Base.perform_deliveries
    end

    def aggregate_weight_for_type(type)
      providers = @providers[type]
      return 0 if providers.empty?

      providers.map(&:weight).inject(0, :+)
    end

    def weighted_provider_for_type(type)
      providers = @providers[type]
      unless providers && providers.any?
        # byebug
        raise ProviderNotFoundError, "Could not find any providers for type:#{type}"
      end

      # get the aggregate weight, and do a rand based on it
      random_index = rand(aggregate_weight_for_type(type))
      # puts "random_index:#{random_index}"

      # loop through each, exclusive range, and find the one that it falls on
      running_total = 0
      providers.each do |provider|
        # puts "running_total:#{running_total}"
        left_index = running_total
        right_index = running_total + provider.weight
        # puts "left_index:#{left_index} right_index:#{right_index}"

        if (left_index...right_index).include?(random_index)
          return provider
        else
          running_total += provider.weight
        end
      end
    end

    def delivery_type_for(rails_message)
      to = extract_to(rails_message, format: :address)

      @config[:mappings].each do |delivery_type, klass|
        return delivery_type if to.instance_of?(klass)
      end

      # if we got here, nothing matched in the mappings table
      raise UnknownDeliveryTypeError, "Cannot determine provider type from provided to:#{to}"
    end

    def deliver!(rails_message)
      # figure out what we're delivering
      delivery_type = delivery_type_for(rails_message)

      # set this on the message so it's available throughout
      rails_message.hermes_type = delivery_type

      # find a provider, weight matters here
      provider = weighted_provider_for_type(delivery_type)

      # and then send the message
      t = Time.now
      begin
        provider.send_message(rails_message)
      rescue Exception => e
        self.track_failure(provider)
        raise e
      ensure
        self.track_attempt(provider, (Time.now - t).to_f)
      end
    end
  end
end

ActionMailer::Base.add_delivery_method :hermes, Hermes::Deliverer
