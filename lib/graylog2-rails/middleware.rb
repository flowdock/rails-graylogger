module Graylog2Rails
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Graylog2Rails::Logger.initialize_log_buffer
      logger = Rails.logger
      request = Rack::Request.new(env)
      RequestStore.store[:ipaddress] = request.ip

      status, headers, body = @app.call(env)

      [status, headers, body]
    end
  end
end
