ENV["RAILS_ENV"] = "test"
require "active_support"
require "active_support/inflector"
require "active_support/core_ext"
require File.expand_path("../../lib/rails-graylogger", __FILE__)

#require "rspec/rails"

RSpec.configure do |config|
  config.filter_run_excluding slow: true unless ENV["CI"] == "true"

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Randomise spec order
#  config.order = :random
#  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = false
  end
end
