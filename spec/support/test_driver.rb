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
  def initialize(element)
    @element = Capybara::Node::Simple.new(element)
  end

  def click(*_args); end

  def find_css(selector)
    @element.find_css(selector).map do |element|
      TestNode.new(element)
    end
  end

  def [](key)
    @element[key]
  end

  def visible?
    @element.visible?
  end
end

Capybara.register_driver(:test) do
  TestDriver.new
end

RSpec.configure do |config|
  config.before { FeedPub::Run.driver = :test }
end
