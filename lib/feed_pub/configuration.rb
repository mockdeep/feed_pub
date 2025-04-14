# frozen_string_literal: true

# helper methods for accessing configuration
module FeedPub::Configuration
  class << self
    attr_writer :driver, :file_path, :max_pages, :output

    # return the driver, :selenium by default
    def driver
      @driver ||= :selenium
    end

    # return the file path, Dir.pwd by default
    def file_path
      @file_path ||= Dir.pwd
    end

    # return the max pages, 50 by default
    def max_pages
      @max_pages ||= 10
    end

    # return the output stream, $stdout by default
    def output
      @output ||= $stdout
    end
  end
end
