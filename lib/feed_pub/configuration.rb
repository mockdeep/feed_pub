# frozen_string_literal: true

require "optparse"

# helper methods for accessing configuration
module FeedPub::Configuration
  class << self
    attr_writer :driver,
                :file_path,
                :image_processors,
                :lighten_images,
                :max_pages,
                :output

    # return the driver, :selenium by default
    def driver
      @driver ||= :selenium
    end

    # return the file path, Dir.pwd by default
    def file_path
      @file_path ||= Dir.pwd
    end

    # return the image processing steps, empty array by default
    def image_processors
      @image_processors ||= []
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

      configure_help(parser)
      configure_image_processors(parser)
      configure_max_pages(parser)

      parser.parse!(args)

      return args.first if args.length == 1

      output.puts parser
      exit
    end

    private

    def configure_help(parser)
      parser.on("-h", "--help", "Prints this help") do
        output.puts parser
        exit
      end
    end

    def configure_image_processors(parser)
      parser.on("--lighten", "Lighten images") { image_processors << :lighten }

      parser.on("--bw", "Convert images to black and white") do
        image_processors << :bw
      end

      parser.on("--colorize", "Colorize images") do
        image_processors << :colorize
      end

      parser.on("--contrast", "Increase image contrast") do
        image_processors << :contrast
      end
    end

    def configure_max_pages(parser)
      message = "Maximum number of pages to fetch (default: 50)"
      parser.on("-m", "--max-pages N", Integer, message) do |max_pages|
        self.max_pages = max_pages
      end
    end
  end
end
