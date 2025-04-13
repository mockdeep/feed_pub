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

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path(__dir__)) do
      `git ls-files -z`.split("\x0").reject do |f|
        (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
      end
    end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("activesupport", "~> 8.0")
  spec.add_dependency("capybara", "~> 3.40")
  spec.add_dependency("http", "~> 5.2")
  spec.add_dependency("selenium-webdriver", "~> 4.31.0")
  spec.metadata["rubygems_mfa_required"] = "true"
end
