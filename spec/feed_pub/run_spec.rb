# frozen_string_literal: true

RSpec.describe FeedPub::Run do
  def filepath
    File.join(Dir.pwd, "tmp")
  end

  def tempfiles
    Dir.glob(File.join(filepath, "*")).map { |f| File.basename(f) }
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
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("one_image", output: StringIO.new, filepath:)

    expect(tempfiles).to eq(["00000_foo.png"])
  end

  it "clicks the next link and downloads images from each page" do
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    stub_request(:get, "https://bar.png").to_return(body: "image data")
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("next_link", output: StringIO.new, filepath:)

    expect(tempfiles).to eq(["00000_foo.png", "00001_bar.png"])
  end

  it "does not download images when already downloaded" do
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    expect(described_class).to receive(:`).with("convert * comic.pdf")

    described_class.call("duplicate_image", output: StringIO.new, filepath:)

    expect(tempfiles).to eq(["00000_foo.png"])
  end

  it "raises an error when image file already exists" do
    stub_request(:get, "https://foo.png").to_return(body: "image data")
    image_path = File.join(filepath, "00000_foo.png")
    File.write(image_path, "image data")

    expect { described_class.call("image_class", output: StringIO.new, filepath:) }
      .to raise_error("File already exists: 00000_foo.png")
  end
end
