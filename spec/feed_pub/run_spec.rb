# frozen_string_literal: true

RSpec.describe FeedPub::Run do
  it "raises an error when no images are found" do
    expect { described_class.call("no_images") }
      .to raise_error("No images on page")
  end

  it "raises an error when no image candidates are found" do
    expect { described_class.call("no_matching_image") }
      .to raise_error("No image candidates found")
  end

  it "raises an error when no next button is found" do
    expect { described_class.call("no_next") }
      .to raise_error("No next candidates found")
  end

  it "downloads images and creates a pdf" do
    stub_request(:get, "https://foo.jpg").to_return(body: sketch)

    described_class.call("one_image")

    expect(temp_files).to eq(["comic.pdf", "images"])
  end

  it "clicks the next link and downloads images from each page" do
    stub_request(:get, "https://foo.jpg").to_return(body: sketch)
    stub_request(:get, "https://bar.jpg").to_return(body: sketch)

    described_class.call("next_link")

    expect(image_files).to eq(["00000_foo.jpg", "00001_bar.jpg"])
  end

  it "does not download images when already downloaded" do
    stub_request(:get, "https://foo.jpg").to_return(body: sketch)

    described_class.call("duplicate_image")

    expect(image_files).to eq(["00000_foo.jpg"])
  end

  it "raises an error when image file already exists" do
    stub_request(:get, "https://foo.jpg").to_return(body: sketch)
    File.write(File.join(images_path, "00000_foo.jpg"), sketch)

    expect { described_class.call("image_class") }
      .to raise_error("File already exists: 00000_foo.jpg")
  end
end
