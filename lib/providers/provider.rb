module Hermes
  class Provider
    attr_reader :defaults, :credentials, :weight

    def initialize(options = {})
      options.symbolize_keys!

      @defaults = options[:defaults]
      @credentials = options[:credentials]
      @weight = options[:weight].to_i

      raise(InvalidWeightException, "Provider name:#{provider_name} has invalid weight:#{@weight}") unless @weight >= 0
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