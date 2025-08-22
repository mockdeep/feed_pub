# frozen_string_literal: true

# match link by icon inside
class FeedPub::NextSelector::IconLink
  attr_accessor :selector

  def initialize(selector)
    self.selector = selector
  end

  # return true if a link with the icon exists
  def matches?(session)
    session.has_css?("a:has(#{selector})", visible: false)
  end

  # click the link with the icon
  def click(session)
    session.visit(link(session)[:href])
  end

  # return the link element with the icon
  def link(session)
    session.find("a:has(#{selector})", visible: false, match: :first)
  end
end
