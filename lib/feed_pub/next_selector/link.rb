# frozen_string_literal: true

class FeedPub::NextSelector::Link
  attr_accessor :text

  def initialize(text)
    self.text = text
  end

  def matches?(session)
    session.has_link?(text, visible: false)
  end

  def click(session)
    session.visit(link(session)[:href])
  end

  def link(session)
    session.find_link(text, visible: false, match: :first)
  end
end
