# frozen_string_literal: true

class TestSession
  attr_accessor :url

  def visit(url)
    self.url = url
  end

  def has_link?(_text)
    false
  end

  def find(_selector); end

  def assert_no_current_path(_url); end
end
