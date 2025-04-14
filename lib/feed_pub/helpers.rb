# frozen_string_literal: true

# helper methods for accessing configuration
module FeedPub::Helpers
  # return the configured output
  def output
    FeedPub::Configuration.output
  end
end
