# frozen_string_literal: true

require "capybara"

class TestDriver
  def visit(url); end

  def invalid_element_errors
    []
  end

  def find_css(_selector, _options)
    []
  end

  def wait?
    false
  end
end

Capybara.register_driver(:test) do
  TestDriver.new
end

RSpec.configure do |config|
  config.before { FeedPub::Run.driver = :test }
end
