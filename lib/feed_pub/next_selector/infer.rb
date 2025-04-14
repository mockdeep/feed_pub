# frozen_string_literal: true

module FeedPub::NextSelector::Infer
  class << self
    include FeedPub::Helpers

    def call(session)
      output.puts "inferring next selector"
      if session.has_link?("Next")
        return FeedPub::NextSelector::Link.new("Next")
      end

      # find all elements with "next" in id or class or alt
      # return the selector from the first one
      selector = "[id*='next'], [class*='next'], [alt*='next']"
      element = session.all(selector).first

      raise FeedPub::Error, "No next candidates found" unless element

      final_selector =
        if element["id"].present?
          FeedPub::NextSelector::Attribute.new("[id='#{element["id"]}']")
        elsif element["alt"].present?
          FeedPub::NextSelector::Attribute.new("[alt='#{element["alt"]}']")
        else
          FeedPub::NextSelector::Attribute.new("[class='#{element["class"]}']")
        end

      output.puts "final next selector: '#{final_selector}'"

      final_selector
    end
  end
end
