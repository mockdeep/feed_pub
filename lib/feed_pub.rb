# frozen_string_literal: true

require "active_support/all"
require "capybara"
require "http"

module FeedPub
end

require_relative "feed_pub/infer_next_selector"
require_relative "feed_pub/run"
require_relative "feed_pub/version"
