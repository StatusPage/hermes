module Hermes
  module Extractors
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

    def extract_hermes_providers(rails_message)
      # extract the filters and get it into an array, will be strings to start
      # in the event of hermes_providers (plural), string will be comma-separated
      # ex. "Hermes::TwilioProvider, Hermes::PlivoProvider"
      filters = extract_custom(rails_message, :hermes_provider) || extract_custom(rails_message, :hermes_providers)

      # bail if we got nothing
      return if filters.nil?

      # if it's a string, we may have 1 or more providers in a comma-separated format
      filters = filters.split(',').map(&:strip) if filters.is_a?(String)

      # if we end up with one item, put it in an array
      filters = [filters] unless filters.is_a?(Array)

      # will either be an array here or nil
      # each item may be a string, or it may be a class
      filters.collect{|filter|
        if filter.is_a?(String)
          filter.constantize
        else
          filter
        end
      }
    end

    def extract_custom(rails_message, attr_name)
      # first use the [] methods to see if we can get at this variable
      # this will happen when we call something like
      # mail(to: 'scott@sp', from: 'fake', plivo_from: '+19196022733')
      attr_value = rails_message[attr_name]

      # this will be an instance of Mail::Field, so we need to call #value on it to get the raw string
      return attr_value.value if attr_value

      # try to call the method on the rails_message
      # this will handle the attr_accessor case where
      # we've monkeypatched Mail::Message
      return rails_message.send(attr_name)
    end

    # format can be full|name|address
    def extract_from(rails_message, format: :full, source: nil)
      from = nil

      # check to see if a source is present, and if it is use the naming convention
      if source.present?
        # we'll set from here, and then fall through
        from = extract_custom(rails_message, "#{source}_from")
      end

      # if a source was specified and value found, from should already be set
      # otherwise we need to fall back to the normal from field
      from ||= rails_message[:from].formatted.first

      # try to do a complex extract on the from, and proceed from there
      from = complex_extract(from)
      return from[:value] if from[:decoded]

      case format
      when :full
        rails_message[:from].formatted.first
      when :name
        rails_message[:from].address_list.addresses.first.name
      when :address
        rails_message[:from].address_list.addresses.first.address
      end
    end

    # format can be full|name|address
    def extract_to(rails_message, format: :full)
      to = complex_extract(rails_message.to.first)
      return to[:value] if to[:decoded]

      case format
      when :full
        rails_message[:to].formatted.first
      when :name
        rails_message[:to].address_list.addresses.first.name
      when :address
        rails_message[:to].address_list.addresses.first.address
      end
    end

    # when passing in to/from addresses that are complex objects
    # like a Hash or Twitter::Client instance, they will be YAMLed
    # and then Base64ed since Mail::Message really only wants
    # to play with strings for these fields
    def complex_extract(address_container)
      if B64Y.decodable?(address_container)
        {
          decoded: true,
          value: B64Y.decode(address_container)
        }
      else
        {
          decoded: false,
          value: address_container
        }
      end
    end
  end
end
