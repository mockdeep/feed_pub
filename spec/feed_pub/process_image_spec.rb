# frozen_string_literal: true

RSpec.describe FeedPub::ProcessImage do
  describe ".call" do
    it "lightens an image" do
      image = Magick::Image.from_blob(sketch).first
      result = described_class.call(image, processors: [:lighten])

      expect(result.difference(image)).to all(be > 0)
    end

    it "converts an image to black and white" do
      image = Magick::Image.from_blob(sketch).first
      result = described_class.call(image, processors: [:bw])

      expect(result.colorspace).to eq(Magick::GRAYColorspace)
    end

    it "colorizes an image" do
      image = Magick::Image.from_blob(sketch).first
      result = described_class.call(image, processors: [:colorize])

      expect(result.difference(image)).to all(be > 0)
    end

    it "increases the contrast of an image" do
      image = Magick::Image.from_blob(sketch).first
      result = described_class.call(image, processors: [:contrast])

      expect(result.difference(image)).to all(be > 0)
    end
  end
end
