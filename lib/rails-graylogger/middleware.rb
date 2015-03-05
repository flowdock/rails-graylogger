module RailsGraylogger
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      RailsGraylogger::Logger.initialize_log_buffer
      logger = Rails.logger
      request = Rack::Request.new(env)
      RequestStore.store[:ipaddress] = request.ip
      RequestStore.store[:x_forwarded_for] = request.env["HTTP_X_FORWARDED_FOR"]

      status, headers, body = @app.call(env)

      [status, headers, body]
    end
  end
end
