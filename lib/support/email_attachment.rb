module Hermes
  class EmailAttachment < StringIO
    # these methods allow us to "trick" RestClient into thinking
    # this object conforms to the File object interface
    # since it only needs these few, we can get away with this
    attr_reader :original_filename, :content_type

    # we also need this one, but it doesn't appear to be used
    attr_reader :path

    # inbound here will be an instance of Mail::Part
    # upon passing attachments to action mailer, things are assigned
    # a content id (CID), as well as retaining their filename
    # and we'll return the original filename based on what type of attachment this is
    def initialize (attachment, *rest)
      @path = ''
      if rest.detect {|opt| opt[:inline] }
        @original_filename = attachment.cid
      else
        @original_filename = attachment.filename
      end
      @content_type = attachment.content_type.split(';')[0]
      super attachment.body.decoded
    end
  end
end