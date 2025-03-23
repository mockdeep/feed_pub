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

  it "downloads images and creates a pdf" do
    session = stub_session
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    element = Capybara.string("<img width='300' src='https://foo.png'></img>")
    image_selector = "[class=''] img"
    allow(session).to receive(:all).and_return([element])
    allow(session).to receive(:all).with(image_selector).and_return([element.find("img")])
    expect(File).to receive(:write).with("00000_foo.png", "image data")
    expect(File).to receive(:write).with(
      "downloaded_images.txt",
      "https://foo.png\n",
      mode: "a",
    )
    expect(File).to receive(:delete).with("downloaded_images.txt")
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("some_url")
  end

  it "clicks the next link and downloads images from each page" do
    session = stub_session
    allow(session).to receive(:has_css?).and_return(true, false)
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    element = Capybara.string("<img width='300' src='https://foo.png'></img>")
    allow(element).to receive(:click)
    allow(session).to receive(:find).and_return(element)
    image_selector = "[class=''] img"
    next_element = Capybara.string("<a href='next'></a>")
    next_selector = "[class=''] a"
    allow(session).to receive(:all).and_return([element], [next_element])
    allow(session).to receive(:all).with(image_selector).and_return([element.find("img")])
    allow(session).to receive(:all).with(next_selector).and_return([next_element])
    expect(File).to receive(:write).with("00000_foo.png", "image data")
    expect(File).to receive(:write).with("00001_foo.png", "image data")
    expect(File).to receive(:write).with(
      "downloaded_images.txt",
      "https://foo.png\n",
      mode: "a",
    ).twice
    expect(File).to receive(:delete).with("downloaded_images.txt")
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("some_url")
  end
end
