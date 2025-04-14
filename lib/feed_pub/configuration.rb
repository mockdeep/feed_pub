# frozen_string_literal: true

# helper methods for accessing configuration
module FeedPub::Configuration
  class << self
    attr_writer :file_path, :output

    # return the output stream, $stdout by default
    def output
      @output ||= $stdout
    end

    # return the file path, Dir.pwd by default
    def file_path
      @file_path ||= Dir.pwd
    end
  end
end
