module Hermes
  class CompleteStatsHandler
    class << self
      def log(method, provider, timing)
        Rails.logger.warn "Hermes method:#{method} provider:#{provider} timing:#{timing}"
      end

      def attempt(provider, timing)
        log(:attempt, provider, timing)

        {
          provider: provider,
          timing: timing
        }
      end

      def success(provider, timing)
        log(:success, provider, timing)

        {
          provider: provider,
          timing: timing
        }
      end

      def failure(provider, timing)
        log(:failure, provider, timing)

        {
          provider: provider,
          timing: timing
        }
      end
    end
  end
end