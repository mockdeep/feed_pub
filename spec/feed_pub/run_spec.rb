# frozen_string_literal: true

RSpec.describe FeedPub::Run do
  def filepath
    File.join(Dir.pwd, "tmp")
  end

  def tempfiles
    Dir.glob(File.join(filepath, "*")).map { |f| File.basename(f) }
  end

  def sketch
    File.read(File.join("spec", "fixtures", "sketch.jpg"))
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
    stub_request(:get, "https://foo.png").to_return(body: sketch)

    described_class.call("one_image", output: StringIO.new, filepath:)

    expect(tempfiles).to eq(["00000_foo.png", "comic.pdf"])
  end

  it "clicks the next link and downloads images from each page" do
    stub_request(:get, "https://foo.png").to_return(body: sketch)
    stub_request(:get, "https://bar.png").to_return(body: sketch)

    described_class.call("next_link", output: StringIO.new, filepath:)

    expect(tempfiles).to eq(["00000_foo.png", "00001_bar.png", "comic.pdf"])
  end

  it "does not download images when already downloaded" do
    stub_request(:get, "https://foo.png").to_return(body: sketch)

    described_class.call("duplicate_image", output: StringIO.new, filepath:)

    expect(tempfiles).to eq(["00000_foo.png", "comic.pdf"])
  end

  it "raises an error when image file already exists" do
    stub_request(:get, "https://foo.png").to_return(body: sketch)
    image_path = File.join(filepath, "00000_foo.png")
    File.write(image_path, sketch)

    expect { described_class.call("image_class", output: StringIO.new, filepath:) }
      .to raise_error("File already exists: 00000_foo.png")
  end
end
