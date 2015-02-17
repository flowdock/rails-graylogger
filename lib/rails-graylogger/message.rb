module RailsGraylogger
  class Message
    FIELD_KEY_REGEXP = /^[\w\.\-]*$/

    attr_accessor :level, :full_message, :short_message, :extra_fields

    def initialize(opts = {})
      @level = opts[:level] || GELF::Levels::INFO
      @short_message = opts[:short_message] || ""
      @full_message = opts[:full_message] || ""
      @extra_fields = {}
    end

    class << self
      def from_event_payload(payload)
        message = self.new
        message.process_event_payload(payload)
        message
      end
    end

    def process_event_payload(payload)
      self.level = level_from_status(payload[:status])
      self.short_message = "#{payload[:controller]}##{payload[:action]} #{payload[:method]} \"#{payload[:path]}\" from #{payload[:ipaddress]}"
      process_extra_fields(payload)
    end

    def tags=(tags)
      raise ArgumentError.new("Not an array: #{tags.inspect}") unless tags.is_a?(Array)
      self.extra_fields[:_tags] = tags.join(" ")
    end

    def to_hash
      {
        level: level,
        short_message: short_message
      }.tap do |hash|
        hash[:full_message] = short_message + "\n" + full_message unless full_message.blank?
      end.merge(extra_fields)
    end

    def process_extra_fields(payload)
      process_exception_data(payload.delete(:exception))

      payload.each do |key, value|
        @extra_fields["_#{key}"] = formatted_value(value) if valid_key?(key)
      end
    end

    private

    def formatted_value(value)
      if value.is_a?(Numeric)
        value
      else
        value.to_s
      end
    end

    def valid_key?(key)
      key.match(FIELD_KEY_REGEXP)
    end

    def level_from_status(status)
      status < 400 ? GELF::Levels::INFO : GELF::Levels::ERROR
    end

    def process_exception_data(exception)
      return unless exception.is_a?(Array)
      @extra_fields["_exception_class"] = exception.first.to_s
      @extra_fields["_exception_message"] = exception.last.to_s
    end
  end
end
