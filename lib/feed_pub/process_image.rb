# frozen_string_literal: true

# Image processing methods
module FeedPub::ProcessImage
  PROCESSORS = [:lighten, :bw, :colorize, :contrast].freeze

  class << self
    # Apply a series of image processing steps to an image
    def call(image, processors:)
      processors.each { |processor| image = __send__(processor, image) }

      image
    end

    private

    def lighten(image)
      image.modulate(1.5, 1.0, 1.0)
    end

    def bw(image)
      image.quantize(256, Magick::GRAYColorspace)
    end

    def colorize(image)
      image.colorize(0.20, 0.20, 0.20, "white")
    end

    def contrast(image)
      image.contrast(true)
    end
  end
end
