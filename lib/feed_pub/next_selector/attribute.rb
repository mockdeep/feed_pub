# frozen_string_literal: true

class FeedPub::NextSelector::Attribute
  attr_accessor :attribute, :term

  def initialize(attribute, term)
    self.attribute = attribute
    self.term = term
  end

  def matches?(session)
    session.has_css?(value)
  end

  def click(session)
    session.find(value).click
  end

  def to_s
    value
  end

  def value
    "[#{@attribute}*='#{@term}']"
  end
end
