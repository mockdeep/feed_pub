# frozen_string_literal: true

module FeedPub::InferNextSelector
  class << self
    include FeedPub::Helpers

    def call(session)
      output.puts "inferring next selector"
      return LinkSelector.new("Next") if session.has_link?("Next")

      # find all elements with "next" in id or class or alt
      # return the selector from the first one
      selector = "[id*='next'], [class*='next'], [alt*='next']"
      element = session.all(selector).first

      raise FeedPub::Error, "No next candidates found" unless element

      final_selector =
        if element["id"].present?
          Selector.new("[id='#{element["id"]}']")
        elsif element["alt"].present?
          Selector.new("[alt='#{element["alt"]}']")
        else
          Selector.new("[class='#{element["class"]}']")
        end

      output.puts "final next selector: '#{final_selector}'"

      final_selector
    end
  end

  class Selector
    def initialize(selector)
      @selector = selector
    end

    def matches?(session)
      session.has_css?(@selector)
    end

    def click(session)
      session.find(@selector).click
    end

    def to_s
      @selector
    end
  end

  class LinkSelector
    def initialize(text)
      @text = text
    end

    def matches?(session)
      session.has_link?(@text, visible: false)
    end

    def click(session)
      session.visit(link(session)[:href])
    end

    def link(session)
      session.find_link(@text, visible: false, match: :first)
    end
  end
end
