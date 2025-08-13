# frozen_string_literal: true

require_relative "lib/feed_pub/version"

Gem::Specification.new do |spec|
  spec.name          = "feed_pub"
  spec.version       = FeedPub::VERSION
  spec.authors       = ["Robert Fletcher"]
  spec.email         = ["lobatifricha@gmail.com"]

  spec.summary       = "Download a web blog's history and publish it to PDF"
  spec.homepage      = "https://github.com/mockdeep/feed_pub"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mockdeep/feed_pub"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject do |file|
        (file == __FILE__) ||
          file.start_with?("bin/", "spec/", ".git", ".github", "Gemfile")
      end
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |file| File.basename(file) }
  spec.require_paths = ["lib"]

  spec.add_dependency("activesupport", "~> 8.0")
  spec.add_dependency("capybara", "~> 3.40")
  spec.add_dependency("http", "~> 5.2")
  spec.add_dependency("rmagick", "~> 6.1")
  spec.add_dependency("selenium-webdriver", "~> 4.35.0")
  spec.metadata["rubygems_mfa_required"] = "true"
end
