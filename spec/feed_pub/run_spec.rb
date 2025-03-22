# frozen_string_literal: true

RSpec.describe FeedPub::Run do
  def stub_session
    session = TestSession.new
    allow(Capybara::Session).to receive(:new).and_return(session)
    session
  end

  it "raises an error when no images are found" do
    stub_session

    expect { described_class.call("some_url") }
      .to raise_error("No image candidates found")
  end

  it "raises an error when no next button is found" do
    session = stub_session
    element = Capybara.string("<img width='300'></img>")
    allow(session).to receive(:all).and_return([element], [])

    expect { described_class.call("some_url") }
      .to raise_error("No next candidates found")
  end
end
