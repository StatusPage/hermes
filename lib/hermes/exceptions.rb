module Hermes
  # if provider is listed in settings, but no provider class is available
  class ProviderNotFoundException < Exception; end

  # thrown if provider weight goes below 1
  class InvalidWeightException < Exception; end
end