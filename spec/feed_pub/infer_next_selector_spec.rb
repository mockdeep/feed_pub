# frozen_string_literal: true

RSpec.describe FeedPub::InferNextSelector do
  it "returns a link selector when a link with 'Next' is found" do
    session = TestNode.new("<a href='/foo'>Next</a>")

    expect(described_class.call(session))
      .to be_a(FeedPub::InferNextSelector::LinkSelector)
  end

  it "returns an alt selector when an element with 'next' in alt is found" do
    session = TestNode.new("<button alt='next'></button>")

    selector = described_class.call(session)

    expect(selector.to_s).to eq("[alt='next']")
  end

  it "returns a class selector when an element with 'next' in class is found" do
    session = TestNode.new("<button class='next'></button>")

    selector = described_class.call(session)

    expect(selector.to_s).to eq("[class='next']")
  end

  describe FeedPub::InferNextSelector::LinkSelector do
    describe "#matches?" do
      it "returns true when the link is found" do
        selector = described_class.new("Next")
        session = TestNode.new("<a href='/foo'>Next</a>")

        expect(selector.matches?(session)).to be(true)
      end

      it "returns false when the link is not found" do
        selector = described_class.new("Next")
        session = TestNode.new("<a href='/foo'>Foo</a>")

        expect(selector.matches?(session)).to be(false)
      end
    end

    describe "#click" do
      it "clicks the link" do
        session = TestNode.new("<a href='next'></a>")
        expect(session).to receive(:visit).with("next")

        described_class.new("").click(session)
      end
    end
  end
end
