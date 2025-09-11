# frozen_string_literal: true

require "optparse"

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
      @max_pages ||= 50
    end

    # return the output stream, $stdout by default
    def output
      @output ||= $stdout
    end

    # parse command line arguments and return the URL
    def parse(args)
      parser = OptionParser.new
      parser.banner = "Usage: feed_pub [options] URL"

      configure_max_pages(parser)
      configure_help(parser)

      parser.parse!(args)

      if args.length != 1
        output.puts parser
        exit
      end

      args.first
    end

    private

    def configure_max_pages(parser)
      message = "Maximum number of pages to fetch (default: 50)"
      parser.on("-m", "--max-pages N", Integer, message) do |max_pages|
        self.max_pages = max_pages
      end
    end

    def configure_help(parser)
      parser.on("-h", "--help", "Prints this help") do
        output.puts parser
        exit
      end
    end
  end
end
