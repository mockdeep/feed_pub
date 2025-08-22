# frozen_string_literal: true

RSpec.describe FeedPub::NextSelector::IconLink do
  describe "#matches?" do
    it "returns true when the link with the icon is found" do
      selector = described_class.new("svg")
      session = TestNode.wrap("<a href='/foo'><svg></svg></a>")

      expect(selector.matches?(session)).to be(true)
    end

    it "returns false when the link with the icon is not found" do
      selector = described_class.new("svg")
      session = TestNode.wrap("<a href='/foo'><div></div></a>")

      expect(selector.matches?(session)).to be(false)
    end
  end

  describe "#click" do
    it "clicks the link with the icon" do
      session = TestNode.wrap("<a href='next'><svg></svg></a>")
      expect(session).to receive(:visit).with("next")

      described_class.new("svg").click(session)
    end
  end

  describe "#link" do
    it "returns the link element with the icon" do
      session = TestNode.wrap("<a href='next'><svg></svg></a>")
      selector = described_class.new("svg")

      link = selector.link(session)

      expect(link[:href]).to eq("next")
    end
  end
end
