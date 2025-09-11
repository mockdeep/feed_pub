# frozen_string_literal: true

RSpec.describe FeedPub::Configuration do
  describe ".parse" do
    it "returns the URL when only URL is provided" do
      url = described_class.parse(["http://example.com"])

      expect(url).to eq("http://example.com")
    end

    it "returns the URL when valid arguments are provided" do
      url = described_class.parse(["-m", "10", "http://example.com"])

      expect(url).to eq("http://example.com")
    end

    it "sets max_pages when -m is provided" do
      described_class.parse(["-m", "10", "http://example.com"])

      expect(described_class.max_pages).to eq(10)
    end

    it "prints help and exits when -h is provided" do
      expect { described_class.parse(["-h"]) }.to raise_error(SystemExit)
    end

    it "prints help and exits when no URL is provided" do
      expect { described_class.parse([]) }.to raise_error(SystemExit)
    end

    it "prints help and exits when multiple URLs are provided" do
      expect { described_class.parse(["http://example.com", "http://foo.com"]) }
        .to raise_error(SystemExit)
    end
  end
end
