# frozen_string_literal: true

module FeedPub::Run
  class << self
    include FeedPub::Helpers

    EXCLUDED_IMAGE_EXTENSIONS = ["", ".gif"].freeze

    attr_accessor :processed_urls

    def call(url)
      Capybara.predicates_wait = false
      session = Capybara::Session.new(driver)
      with_retry { session.visit(url) }

      unless session.has_css?("img", wait: 5)
        raise FeedPub::Error, "No images on page"
      end

      image_selector = FeedPub::ImageSelector::Infer.call(session)
      next_selector = FeedPub::NextSelector::Infer.call(session)
      self.processed_urls = []

      # need to number the images in case they don't have sequenced names
      sequence = "00000"
      image_selector.all(session).each do |img|
        sequence = download_image(img, referer: url, sequence:)
      end

      while next_selector.matches?(session) && Integer(sequence, 10) < max_pages
        current_url = session.current_url
        output.puts "current url: #{current_url}"
        next_selector.click(session)

        begin
          session.assert_no_current_path(current_url)
          output.puts "new current url: #{session.current_url}"
        rescue Capybara::ExpectationNotMet
          output.puts "URL did not change, stopping"
          break
        end

        with_retry do
          image_selector.all(session).each do |img|
            sequence = download_image(img, referer: url, sequence:)
          end
        end
      end

      # merge all images (png, jpg, etc.) into a single PDF
      image_list = Magick::ImageList.new(*Dir.glob(File.join(images_path, "*")))
      image_list.write(File.join(file_path, "comic.pdf"))
      # `convert comic.pdf -fill white -colorize 20% comic_light.pdf`
      # `convert -brightness-contrast 20x20 comic.pdf comic_bright.pdf`
      # `pdftoppm -png -gray some.pdf some`
      output.puts "done"
    end

    private

    def download_image(img, referer:, sequence:)
      image_url = img["data-url"] || img["src"]

      if EXCLUDED_IMAGE_EXTENSIONS.include?(File.extname(image_url).downcase)
        output.puts "skipping excluded extension: #{image_url.inspect}"
        return sequence
      end

      if processed_urls.include?(image_url)
        output.puts "already downloaded: #{image_url}"
        return sequence
      end

      output.puts "downloading #{sequence}/#{max_pages}: #{image_url.inspect}"

      filename = "#{sequence}_#{File.basename(image_url)}"
      image_path = File.join(images_path, filename)

      # ensure multiple images don't have the same name
      # if they do, we'll need to adjust our algorithm
      if File.exist?(image_path)
        raise FeedPub::Error, "File already exists: #{filename}"
      end

      response = HTTP.follow.get(image_url, headers: { Referer: referer })

      File.write(image_path, response.body.to_s)
      processed_urls << image_url
      sequence.next
    end
  end
end
