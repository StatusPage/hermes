module Hermes
  class Provider
    attr_reader :defaults, :credentials, :weight

    class << self
      attr_accessor :_required_credentials

      def required_credentials(*args)
        self._required_credentials  = args.to_a
      end
    end

    def initialize(options = {})
      options.symbolize_keys!

      @defaults = options[:defaults]
      @credentials = options[:credentials].symbolize_keys
      @weight = options[:weight].to_i

      if self.class._required_credentials.try(:any?)
        # provider defines required credentials, let's make sure to check we have everything we need
        if !((@credentials.keys & self.class._required_credentials) == self.class._required_credentials)
          # we're missing something, raise here for hard failure
          raise(InsufficientCredentialsError, "Credentials passed:#{@credentials.keys} do not satisfy all required:#{self.class._required_credentials}")
        end
      end

      unless @weight >= 0
        # provider weights need to be 0 (disabled), or greater than 0 to show as active
        raise(InvalidWeightError, "Provider name:#{provider_name} has invalid weight:#{@weight}")
      end
    end

    def provider_name
      self.class.name.demodulize.underscore.gsub('_provider', '')
    end

    # @see http://stackoverflow.com/questions/4868205/rails-mail-getting-the-body-as-plain-text
    def extract_html(rails_message)
      if rails_message.html_part
        rails_message.html_part.body.decoded
      else
        rails_message.content_type =~ /text\/html/ ? rails_message.body.decoded : nil
      end
    end

    def extract_text(rails_message)
      if rails_message.multipart?
        rails_message.text_part ? rails_message.text_part.body.decoded.strip : nil
      else
        rails_message.content_type =~ /text\/plain/ ? rails_message.body.decoded.strip : nil
      end
    end
  end
end