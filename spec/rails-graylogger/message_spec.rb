require "spec_helper"

describe RailsGraylogger::Message do
  describe "#process_extra_fields" do
    before(:each) do
      @msg = RailsGraylogger::Message.new
    end

    it "should add undescrore before field names" do
      @msg.process_extra_fields({ test: "abc" })
      expect(@msg.extra_fields).to eq({ "_test" => "abc" })
    end

    it "should keep numeric values" do
      @msg.process_extra_fields({ test: 123 })
      expect(@msg.extra_fields).to eq({ "_test" => 123 })
    end

    it "should convert hash to string" do
      @msg.process_extra_fields({ test: { foo: "bar" } })
      expect(@msg.extra_fields).to eq({ "_test" => "{:foo=>\"bar\"}" })
    end

    it "should process the exception data" do
      exception = [ RuntimeError, "test" ]
      @msg.process_extra_fields({ exception: exception })
      expect(@msg.extra_fields).to eq({ "_exception_class" => "RuntimeError", "_exception_message" => "test" })
    end
  end
end
