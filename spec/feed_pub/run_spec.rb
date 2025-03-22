# frozen_string_literal: true

RSpec.describe FeedPub::Run do
  it "raises an error when no images are found" do
    url = "https://xkcd.com"
    session = instance_double(Capybara::Session, visit: nil, all: [])
    allow(Capybara::Session).to receive(:new).and_return(session)

    expect { described_class.call(url) }
      .to raise_error("No image candidates found")
  end
end
