module Hermes
  # if provider is listed in settings, but no provider class is available
  class ProviderNotFoundError < StandardError; end

  # thrown if provider weight goes below 1
  class InvalidWeightError < StandardError; end

  # thrown if 
  class InsufficientCredentialsError < StandardError; end
end