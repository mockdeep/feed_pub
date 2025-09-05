# frozen_string_literal: true

module Matchers
  def invoke(expected_method)
    Matchers::InvokeMatcher.new(expected_method)
  end
end

Dir[File.join(__dir__, "./matchers/*.rb")].each { |path| require path }
