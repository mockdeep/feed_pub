module FeedPub::InferNextSelector
  class << self
    def call(session)
      puts "inferring next selector"
      # find all elements with "next" in id or class or alt
      # return the selector from the first one
      selector = "[id*='next'i], [class*='next'i], [alt*='next'i]"
      element = session.all(selector).first

      if element.nil? && session.has_link?("Next")
        return LinkSelector.new("Next")
      end

      raise "No next candidates found" unless element

      final_selector =
        if element["id"].present?
          Selector.new("[id='#{element["id"]}']")
        elsif element["alt"].present?
          Selector.new("[alt='#{element["alt"]}']")
        else
          Selector.new("[class='#{element["class"]}']")
        end

      puts "final next selector: '#{final_selector}'"

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
  end

  class LinkSelector
    def initialize(text)
      @text = text
    end

    def matches?(session)
      session.has_link?(@text)
    end

    def click(session)
      session.click_link(@text)
    end
  end

end
