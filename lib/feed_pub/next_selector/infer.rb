# frozen_string_literal: true

module FeedPub::NextSelector::Infer
  SELECTORS = [
    FeedPub::NextSelector::Link.new("Next"),
    FeedPub::NextSelector::Attribute.new("id", "next"),
    FeedPub::NextSelector::Attribute.new("class", "next"),
    FeedPub::NextSelector::Attribute.new("alt", "next"),
  ].freeze

  class << self
    include FeedPub::Helpers

    def call(session)
      output.puts "inferring next selector"

      final_selector = SELECTORS.find { |selector| selector.matches?(session) }

      raise FeedPub::Error, "No next candidates found" unless final_selector

      output.puts "final next selector: '#{final_selector}'"

      final_selector
    end
  end
end
