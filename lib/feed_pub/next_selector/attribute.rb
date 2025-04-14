# frozen_string_literal: true

class FeedPub::NextSelector::Attribute
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
