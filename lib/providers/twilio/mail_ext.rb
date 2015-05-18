module Mail
  class Message
    # the URL to be called back for status notifications (sent, delivered, failed, etc)
    attr_accessor :twilio_status_callback

    # special field to specify twilio-only 'from'
    attr_accessor :twilio_from
  end
end