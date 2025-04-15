# frozen_string_literal: true

# match element by attribute
class FeedPub::ImageSelector::Attribute
  attr_accessor :attribute, :term

  def initialize(attribute)
    self.attribute = attribute
  end

  # return all elements that match the selector
  def all(session)
    session.all(value)
  end

  # return whether the selector matches the element and store the term
  def matches?(element)
    if element[attribute].present? && element.has_css?("img")
      self.term = element[attribute]
      true
    else
      false
    end
  end

  # return the string selector
  def value
    "[#{attribute}='#{term}'] img"
  end

  # return the string selector
  def to_s
    value
  end
end
