# frozen_string_literal: true

# helper methods for accessing configuration
module FeedPub::Configuration
  class << self
    attr_writer :output

    # return the output stream, $stdout by default
    def output
      @output ||= $stdout
    end
  end
end
