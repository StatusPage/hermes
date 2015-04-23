module Hermes
  class CompleteStatsHandler
    class << self
      def attempt(provider, timing)
        {
          provider: provider,
          timing: timing
        }
      end

      def success(provider, timing)
        {
          provider: provider,
          timing: timing
        }
      end

      def failure(provider, timing)
        {
          provider: provider,
          timing: timing
        }
      end
    end
  end
end