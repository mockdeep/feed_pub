# frozen_string_literal: true

require "active_support/all"
require "capybara"
require "http"
require "rmagick"

module FeedPub
end

require_relative "feed_pub/configuration"
require_relative "feed_pub/error"
require_relative "feed_pub/helpers"
require_relative "feed_pub/image_selector"
require_relative "feed_pub/next_selector"
require_relative "feed_pub/process_image"
require_relative "feed_pub/retry"
require_relative "feed_pub/run"
require_relative "feed_pub/version"
