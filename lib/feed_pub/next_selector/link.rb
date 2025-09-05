# frozen_string_literal: true

class FeedPub::NextSelector::Link
  include FeedPub::Helpers

  attr_accessor :text

  def initialize(text)
    self.text = text
  end

  def matches?(session)
    session.has_link?(text, visible: false)
  end

  def click(session)
    with_retry { session.visit(link(session)[:href]) }
  end

  def link(session)
    session.find_link(text, visible: false, match: :first)
  end
end
