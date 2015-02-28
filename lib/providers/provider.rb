require 'ostruct'

module Hermes
  class Provider
    attr_reader :defaults, :credentials, :weight

    def initialize(options = {})
      options.symbolize_keys!

      @defaults = options.delete(:defaults)
      @credentials = options.delete(:credentials)
      @weight = options.delete(:weight).to_i

      raise(InvalidWeightException, "Provider name:#{provider_name} has invalid weight:#{@weight}") unless @weight >= 0
    end

    def provider_name
      self.class.name.demodulize.underscore.gsub('_provider', '')
    end
  end
end