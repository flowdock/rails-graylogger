module RailsGraylogger
  class LogSubscriber < ::ActiveSupport::LogSubscriber

    def process_action(event)
      payload = event.payload
      payload[:path] = URI(payload[:path]).path if payload[:path]
      payload[:ipaddress] = RequestStore.store[:ipaddress]
      payload[:duration] = event.duration.round
      payload[:status] = status_from_exception(payload[:exception]) unless payload[:status].present?

      message = RailsGraylogger::Message.from_event_payload(payload)
      message.tags = RailsGraylogger::Logger.request_tags
      message.full_message = buffered_messages

      RailsGraylogger::Notifier.notify!(message.to_hash)
    rescue => ex
      Rails.logger.error "Exception in RailsGraylogger: #{ex.class}: #{ex.message}"
    end

    def buffered_messages
      unless RailsGraylogger::Logger.request_buffer.blank?
        RailsGraylogger::Logger.request_buffer.map{ |item| item[:short_message] unless item[:short_message].blank? }.compact.join("\n")
      else
        []
      end
    end

    def status_from_exception(exception)
      if exception.present?
        exception_class_name = exception.first
        ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
      end
    end
  end
end

RailsGraylogger::LogSubscriber.attach_to :action_controller
