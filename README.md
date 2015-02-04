# graylog2-rails
Rails logs to Graylog2

# Configuring Middleware
Add the following to config/application.rb:

```
config.middleware.insert_before Rack::Runtime, Graylog2Rails::Middleware
config.after_initialize do
  config.logger = Rails.logger = Graylog2Rails::Logger.new(Rails.logger)
end
```

# Watching output without graylog2
One way is to use logstash to listen for gelf input and output it to a file

Config:

```
input {
  gelf {
  }
}
output {
  file {
    path => "/tmp/test.log"
  }
}
```

```
brew install logstash
logstash -f <path_to_config>
```
