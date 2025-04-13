# frozen_string_literal: true

require_relative "support/coverage"
require_relative "support/output"
require_relative "support/test_driver"
require_relative "support/webmock"

require_relative "../lib/feed_pub"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end

  config.filter_run_when_matching(:focus)
  config.order = "random"
end
