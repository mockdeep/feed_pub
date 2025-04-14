# frozen_string_literal: true

RSpec.describe FeedPub::NextSelector::Link do
  describe "#matches?" do
    it "returns true when the link is found" do
      selector = described_class.new("Next")
      session = TestNode.wrap("<a href='/foo'>Next</a>")

      expect(selector.matches?(session)).to be(true)
    end

    it "returns false when the link is not found" do
      selector = described_class.new("Next")
      session = TestNode.wrap("<a href='/foo'>Foo</a>")

      expect(selector.matches?(session)).to be(false)
    end
  end

  describe "#click" do
    it "clicks the link" do
      session = TestNode.wrap("<a href='next'></a>")
      expect(session).to receive(:visit).with("next")

      described_class.new("").click(session)
    end
  end
end
