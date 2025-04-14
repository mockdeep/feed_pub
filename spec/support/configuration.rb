# frozen_string_literal: true

RSpec.configure do |config|
  config.before { FeedPub::Configuration.output = StringIO.new }
end
