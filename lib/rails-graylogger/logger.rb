module RailsGraylogger
  class Logger
    FIELD_KEY_REGEXP = /^[\w\.\-]*$/

    def initialize(logger)
      @logger = logger
    end

    class << self
      def initialize_log_buffer
        RequestStore.store[:graylog2_buffer] = []
      end

      def request_tags
        RequestStore.store[:graylog2_tags] ||= []
      end

      def request_buffer
        RequestStore.store[:graylog2_buffer]
      end
    end

    def tagged(*new_tags, &block)
      new_tags = Array.wrap(new_tags).flatten.reject(&:blank?)
      self.class.request_tags << new_tags - ( self.class.request_tags & new_tags )
      @logger.send("tagged", *new_tags, &block)
    end

    private

    def method_missing(method, *args, &block)
      if [:add, :info, :debug, :warn, :error, :fatal].include?(method) && !args[0].nil?
        if args.size == 1 && args[0].is_a?(String)
          hash = { short_message: args[0] }
        else
          return if args.blank?
          hash = {}
          args.compact.each { |arg| hash.merge!(arg) }
          hash = { short_message: hash.inspect }
        end

        unless self.class.request_buffer.nil?
          self.class.request_buffer << hash
        else
          notify!(method, hash)
        end
      end
      @logger.send(method, *args, &block)
    end

    def notify!(method, payload)
      message = RailsGraylogger::Message.new({
        level: "GELF::Levels::#{method.upcase}".constantize,
        short_message: payload.delete(:short_message)
      })
      message.process_extra_fields(payload)
      message.tags = self.class.request_tags.join(",") unless self.class.request_tags.blank?
      RailsGraylogger::Notifier.notify!(message.to_hash)
    end
  end
end
