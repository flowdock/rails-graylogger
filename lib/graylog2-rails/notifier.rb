module Graylog2Rails
  class Notifier
    class << self
      def notify!(gelf_message)
        @@notifier ||= self.new
        @@notifier.notify!(gelf_message)
      end
    end

    def initialize
      @gelf_notifier = GELF::Notifier.new(remote_host, remote_port, 1420, facility: facility, host: sender_host)
    end

    def remote_host
      ENV["GRAYLOG_HOST"] || "127.0.0.1"
    end

    def remote_port
      ENV["GRAYLOG_PORT"] || 12201
    end

    def facility
      ENV["GRAYLOG_FACILITY"] || "Rails"
    end

    def sender_host
      Socket.gethostname.split(".").first
    end

    def notify!(gelf_message)
      return if Rails.env == 'test'
      @gelf_notifier.notify!(gelf_message.merge(timestamp: Time.now.utc.to_f))
    end
  end
end
