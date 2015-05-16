module ActionMailer
  class MessageDelivery
    if Rails.version.include? "4.2"
      def deliver
        deliver_now
      end
    end
  end
end