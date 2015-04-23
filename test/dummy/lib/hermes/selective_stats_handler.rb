module Hermes
  class SelectiveStatsHandler
    class << self
      def attempt(provider, timing)
        {
          provider: provider,
          timing: timing
        }
      end

      # success and failure are not defined here just to make sure
      # things dont blow up when we try to call them
    end
  end
end