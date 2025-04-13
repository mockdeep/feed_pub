# frozen_string_literal: true

RSpec.describe FeedPub::Run do
  def stub_session
    session = TestSession.new
    allow(Capybara::Session).to receive(:new).and_return(session)
    session
  end

  def filepath
    File.join(Dir.pwd, "tmp")
  end

  def processed_path
    File.join(filepath, "downloaded_images.txt")
  end

  after do
    FileUtils.rm_rf(File.join(filepath, "*"))
  end

  it "raises an error when no images are found" do
    expect { described_class.call("no_images", output: StringIO.new, filepath:) }
      .to raise_error("No image candidates found")
  end

  it "raises an error when no next button is found" do
    expect { described_class.call("no_next", output: StringIO.new, filepath:) }
      .to raise_error("No next candidates found")
  end

  it "downloads images and creates a pdf" do
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    image_path = File.join(filepath, "00000_foo.png")
    expect(File).to receive(:write).with(image_path, "image data")
    expect(File).to receive(:write).with(
      processed_path,
      "https://foo.png\n",
      mode: "a",
    )
    expect(File).to receive(:delete).with(processed_path)
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("one_image", output: StringIO.new, filepath:)
  end

  it "clicks the next link and downloads images from each page" do
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    stub_request(:get, "https://bar.png").to_return(body: "image data")
    image_path_1 = File.join(filepath, "00000_foo.png")
    expect(File).to receive(:write).with(image_path_1, "image data")
    image_path_2 = File.join(filepath, "00001_bar.png")
    expect(File).to receive(:write).with(image_path_2, "image data")
    expect(File).to receive(:write).with(
      processed_path,
      "https://foo.png\n",
      mode: "a",
    )
    expect(File).to receive(:write).with(
      processed_path,
      "https://bar.png\n",
      mode: "a",
    )
    expect(File).to receive(:delete).with(processed_path)
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("next_link", output: StringIO.new, filepath:)
  end

  it "does not download images when already downloaded" do
    File.write(processed_path, "https://foo.png\n")

    stub_request(:get, "https://foo.png").to_return(body: "image data")
    expect(File).not_to receive(:write)
    expect(File).to receive(:delete).with(processed_path)
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("one_image", output: StringIO.new, filepath:)
  end

  it "raises an error when image file already exists" do
    session = stub_session
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    element = Capybara.string("<img width='300' src='https://foo.png'></img>")
    image_selector = "[class=''] img"
    allow(session).to receive(:all).and_return([element])
    allow(session).to receive(:all).with(image_selector).and_return([element.find("img")])
    allow(File).to receive(:exist?).with(processed_path).and_return(false)
    image_path = File.join(filepath, "00000_foo.png")
    allow(File).to receive(:exist?).with(image_path).and_return(true)
    expect { described_class.call("some_url", output: StringIO.new, filepath:) }
      .to raise_error("File already exists: 00000_foo.png")
  end
end
