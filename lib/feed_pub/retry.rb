# frozen_string_literal: true

# module to provide retry logic for operations that may fail intermittently
module FeedPub::Retry
  extend FeedPub::Helpers

  MAX_ATTEMPTS = 5

  class << self
    # Call the given block with retry logic
    def call
      attempt ||= 1

      yield
    rescue StandardError => e
      raise e if attempt >= MAX_ATTEMPTS

      output.puts "Attempt #{attempt} failed: #{e.message}. Retrying..."
      sleep(2**attempt)
      attempt += 1
      retry
    end
  end
end
