# frozen_string_literal: true

require "capybara"

class TestDriver
  attr_accessor :current_url, :body

  def visit(url)
    self.current_url = url
    self.body = Capybara.string(fixture(url))
  end

  def invalid_element_errors
    []
  end

  def find_css(selector, _options)
    body.find_css(selector).map do |element|
      TestNode.new(element)
    end
  end

  def find_xpath(selector)
    body.find_xpath(selector).map do |element|
      TestNode.new(element)
    end
  end

  def wait?
    false
  end

  def fixture(url)
    File.read(File.join(fixture_path, "#{url}.html"))
  end

  def fixture_path
    File.join("spec", "fixtures")
  end
end

class TestNode
  attr_accessor :element

  def initialize(element)
    self.element =
      if element.is_a?(Capybara::Node::Simple)
        element
      else
        Capybara::Node::Simple.new(element)
      end
  end

  def click(*_args); end

  def find_css(selector)
    element.find_css(selector).map do |element|
      TestNode.new(element)
    end
  end

  def all(selector)
    element.all(selector).map do |element|
      TestNode.new(element)
    end
  end

  def has_link?(text, **_options)
    element.has_link?(text)
  end

  def find_link(text, **_options)
    TestNode.new(element.find_link(text))
  end

  def [](key)
    element[key]
  end

  def visible?
    element.visible?
  end
end

Capybara.register_driver(:test) do
  TestDriver.new
end

RSpec.configure do |config|
  config.before { FeedPub::Run.driver = :test }
end
