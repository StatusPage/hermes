module Hermes
  # if provider type is not available
  class ProviderTypeNotFoundError < StandardError; end

  # if provider is listed in settings, but no provider class is available
  class ProviderNotFoundError < StandardError; end

  # thrown if a provider doesn't define the send_message method
  class ProviderInterfaceError < StandardError; end

  # thrown if provider weight goes below 1
  class InvalidWeightError < StandardError; end

  # thrown if configuration does not provide all required credentials 
  class InsufficientCredentialsError < StandardError; end

  # thrown if deliverer cannot figure out what type of provider to use for provided rails message
  class UnknownDeliveryTypeError < StandardError; end
end