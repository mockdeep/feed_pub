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

    it "adds :lighten to image_processors when --lighten is provided" do
      described_class.parse(["--lighten", "http://example.com"])

      expect(described_class.image_processors).to eq([:lighten])
    end

    it "adds :bw to image_processors when --bw is provided" do
      described_class.parse(["--bw", "http://example.com"])

      expect(described_class.image_processors).to eq([:bw])
    end

    it "adds :colorize to image_processors when --colorize is provided" do
      described_class.parse(["--colorize", "http://example.com"])

      expect(described_class.image_processors).to eq([:colorize])
    end

    it "adds :contrast to image_processors when --contrast is provided" do
      described_class.parse(["--contrast", "http://example.com"])

      expect(described_class.image_processors).to eq([:contrast])
    end

    it "adds multiple processors to image_processors" do
      args = ["--lighten", "--bw", "--lighten", "http://example.com"]
      described_class.parse(args)

      expect(described_class.image_processors).to eq([:lighten, :bw, :lighten])
    end
  end
end
