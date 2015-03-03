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

    # format can be full|name|address
    def extract_from(rails_message, format: :full)
      from = complex_extract(rails_message.from.first)
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