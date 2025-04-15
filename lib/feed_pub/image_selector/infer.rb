# frozen_string_literal: true

module FeedPub::ImageSelector::Infer
  SELECTORS = [
    FeedPub::ImageSelector::Attribute.new("class"),
    FeedPub::ImageSelector::Attribute.new("id"),
  ].freeze

  class << self
    include FeedPub::Helpers

    def call(session)
      output.puts "inferring image selector"

      image = biggest_image(session)
      selector = find_selector(image)

      raise FeedPub::Error, "No image candidates found" unless selector

      output.puts "final image selector: '#{selector}'"

      selector
    end

    def biggest_image(session)
      session.all("img").max_by do |img|
        Integer(img["width"]) * Integer(img["height"])
      end
    end

    def find_selector(element)
      return if element.tag_name == "body"

      selector = SELECTORS.find { |selector| selector.matches?(element) }

      selector || find_selector(element.find(:xpath, ".."))
    end
  end
end
