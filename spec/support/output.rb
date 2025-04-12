# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    allow($stdout).to receive(:puts).and_raise("Kernel.puts called")
  end
end
