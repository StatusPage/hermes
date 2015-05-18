module Mail
  class Message
    # the URL to be called back for status notifications (sent, delivered, failed, etc)
    attr_accessor :plivo_status_callback

    # special field to specify plivo-only 'from'
    attr_accessor :plivo_from
  end
end