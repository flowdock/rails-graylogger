require "spec_helper"

describe RailsGraylogger::Logger do
  before :each do
    RequestStore.clear!
    @logger = RailsGraylogger::Logger.new(ActiveSupport::TaggedLogging.new(Logger.new("test.log")))
  end

  it "sends log lines to Graylog server" do
    expect(RailsGraylogger::Notifier).to receive(:notify!).with(level: GELF::Levels::INFO, short_message: "Foobar").once
    @logger.info("Foobar")
  end

  it "handles tagged logging with nested tags" do
    expect(RailsGraylogger::Notifier).to receive(:notify!).with(level: GELF::Levels::INFO, short_message: "Test", _tags: "Foo,Bar").once
    @logger.tagged("Foo") do
      @logger.tagged("Bar") do
        @logger.info("Test")
      end
    end
  end

  it "handles tagged logging with multiple log lines" do
    expect(RailsGraylogger::Notifier).to receive(:notify!).with(_tags: "Foobar", short_message: "Line1", level: GELF::Levels::INFO).once
    expect(RailsGraylogger::Notifier).to receive(:notify!).with(_tags: "Foobar", short_message: "Line2", level: GELF::Levels::INFO).once
    @logger.tagged("Foobar") do
      @logger.info("Line1")
      @logger.info("Line2")
    end
  end

  it "handles passing a hash as argument" do
    hash = { foo: "test", bar: "test" }
    expect(RailsGraylogger::Notifier).to receive(:notify!).with(level: GELF::Levels::INFO, short_message: "{:foo=>\"test\", :bar=>\"test\"}", _tags: "Foobar").once
    @logger.tagged("Foobar") do
      @logger.info(hash)
    end
  end

  it "should buffer logging output when request store is initialized" do
    allow(RailsGraylogger::Notifier).to receive(:notify!)
    RailsGraylogger::Logger.initialize_log_buffer
    expect(RailsGraylogger::Logger.request_buffer.size).to eq(0)
    @logger.info("Foobar")
    expect(RailsGraylogger::Notifier).not_to have_received(:notify!)
    expect(RailsGraylogger::Logger.request_buffer.size).to eq(1)
    expect(RailsGraylogger::Logger.request_buffer[0]).to eq({short_message: "Foobar"})
  end
end
