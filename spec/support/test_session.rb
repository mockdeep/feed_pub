# frozen_string_literal: true

class TestSession
  def visit(url); end

  def all(_selector)
    []
  end

  def has_css?(_selector)
    false
  end

  def has_link?(_text)
    false
  end
end
