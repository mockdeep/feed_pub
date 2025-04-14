# frozen_string_literal: true

module FeedPub::ImageSelector::Infer
  class << self
    include FeedPub::Helpers

    def call(session)
      output.puts "inferring image selector"
      # find all elements on the page with "comic" in id or class
      # then find the ones with no children matching the same criteria
      # then find the one with the biggest image
      selector = "[id*='comic'], [class*='comic'], .viewer_img"
      candidates =
        session.all(selector).select do |element|
          element.has_no_css?(selector) && element.has_css?("img")
        end

      element =
        candidates.max_by do |candidate|
          candidate.all("img").map { |img| Integer(img["width"]) }.max
        end

      raise FeedPub::Error, "No image candidates found" unless element

      final_selector =
        if element["id"].present?
          "[id='#{element["id"]}'] img"
        else
          "[class='#{element["class"]}'] img"
        end

      output.puts "final image selector: '#{final_selector}'"

      final_selector
    end
  end
end
