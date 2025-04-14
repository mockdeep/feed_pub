# frozen_string_literal: true

RSpec.configure do |config|
  config.before { FeedPub::Configuration.output = StringIO.new }

  config.around do |example|
    Dir.mktmpdir do |dir|
      FeedPub::Configuration.file_path = dir
      example.run
      FeedPub::Configuration.file_path = nil
    end
  end
end
