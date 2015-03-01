require 'digest/md5'

module Hermes
  class Deliverer

    attr_accessor :providers

    def initialize(settings)
      @providers = {}

      [:email, :sms, :webhook].each do |provider_type|
        @providers[provider_type] ||= []
        providers = settings[provider_type]
        next unless providers.try(:any?)

        # go through all of the providers and initialize each
        providers.each do |provider_name, options|
          # check to see that the provider class exists
          provider_proper_name = "#{provider_name}_provider".camelize.to_sym
          raise(ProviderNotFoundException, "Could not find provider class Hermes::#{provider_proper_name}") unless Hermes.constants.include?(provider_proper_name)

          # initialize the provider with the given weight, defaults, and credentials
          provider = Hermes.const_get(provider_proper_name).new(options)
          @providers[provider_type] << provider
        end

        # make sure the provider type has an aggregate weight of more than 1
        aweight = aggregate_weight_for_type(provider_type)
        raise(InvalidWeightException, "Provider type:#{provider_type} has aggregate weight:#{aweight}") unless aweight > 0
      end
    end

    def aggregate_weight_for_type(type)
      providers = @providers[type]
      return 0 if providers.empty?

      providers.map(&:weight).inject(0, :+)
    end

    def weighted_provider_for_type(type)
      providers = @providers[type]
      return nil if providers.empty?

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
      if rails_message.to.first.start_with?('@')
        :tweet
      elsif rails_message.to.first.include?('@')
        :email
      elsif rails_message.to.first.include?('://')
        :webhook
      else
        :sms
      end
    end

    def deliver!(rails_message)
      byebug
      provider = weighted_provider_for_type(delivery_type_for(rails_message))
      provider.send_message(rails_message)
    end
  end
end

ActionMailer::Base.add_delivery_method :hermes, Hermes::Deliverer