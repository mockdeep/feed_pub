# frozen_string_literal: true

require "capybara"

class TestNode
  attr_accessor :current_url, :element

  class << self
    def wrap(element)
      new(Capybara::Node::Simple.new(element))
    end
  end

  def initialize(element)
    self.element = element
  end

  def [](key)
    element[key]
  end

  def all(selector)
    element.all(selector).map { |element| TestNode.new(element) }
  end

  def click(*_args); end

  def find_css(selector, _options)
    element.find_css(selector).map { |element| TestNode.wrap(element) }
  end

  def find_link(text, **_options)
    TestNode.new(element.find_link(text))
  end

  def find_xpath(selector)
    element.find_xpath(selector).map { |element| TestNode.wrap(element) }
  end

  def fixture(url)
    File.read(File.join(fixture_path, "#{url}.html"))
  end

  def fixture_path
    File.join("spec", "fixtures")
  end

  def has_link?(text, **_options)
    element.has_link?(text)
  end

  def invalid_element_errors
    []
  end

  def visible?
    element.visible?
  end

  def visit(url)
    self.current_url = url
    self.element = Capybara.string(fixture(url))
  end

  def wait?
    false
  end
end

Capybara.register_driver(:test) { TestNode.wrap("") }
