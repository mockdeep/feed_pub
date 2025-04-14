# frozen_string_literal: true

RSpec.describe FeedPub::NextSelector::Infer do
  it "returns a link selector when a link with 'Next' is found" do
    session = TestNode.new("<a href='/foo'>Next</a>")

    expect(described_class.call(session)).to be_a(FeedPub::NextSelector::Link)
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
end
