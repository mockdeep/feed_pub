# frozen_string_literal: true

RSpec.describe FeedPub::InferNextSelector do
  it "returns a link selector when a link with 'Next' is found" do
    session = TestSession.new
    expect(session).to receive(:has_link?).with("Next").and_return(true)

    expect(described_class.call(session, output: StringIO.new)).to be_a(FeedPub::InferNextSelector::LinkSelector)
  end

  it "returns an alt selector when an element with 'next' in alt is found" do
    session = TestSession.new
    element = Capybara.string("<button alt='next'></button>").find("button")
    allow(session).to receive(:all).and_return([element])

    selector = described_class.call(session, output: StringIO.new)

    expect(selector.to_s).to eq("[alt='next']")
  end

  it "returns a class selector when an element with 'next' in class is found" do
    session = TestSession.new
    element = Capybara.string("<button class='next'></button>").find("button")
    allow(session).to receive(:all).and_return([element])

    selector = described_class.call(session, output: StringIO.new)

    expect(selector.to_s).to eq("[class='next']")
  end

  describe FeedPub::InferNextSelector::LinkSelector do
    describe "#matches?" do
      it "returns true when the link is found" do
        session = TestSession.new
        allow(session).to receive(:has_link?).and_return(true)
        selector = described_class.new("Next")

        expect(selector.matches?(session)).to be(true)
      end

      it "returns false when the link is not found" do
        session = TestSession.new
        allow(session).to receive(:has_link?).and_return(false)
        selector = described_class.new("Next")

        expect(selector.matches?(session)).to be(false)
      end
    end

    describe "#click" do
      it "clicks the link" do
        session = TestSession.new
        element = Capybara.string("<a href='next'></a>").find("a")
        allow(session).to receive(:find_link).and_return(element)
        expect(session).to receive(:visit).with("next")

        described_class.new("").click(session)
      end
    end
  end
end
