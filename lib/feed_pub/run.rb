# frozen_string_literal: true

module FeedPub::Run
  class << self
    PROCESSED_URLS = "downloaded_images.txt"
    DEFAULT_MAX_PAGES = 200

    def call(url, max_pages: DEFAULT_MAX_PAGES)
      image_selector = ".comic-page > img"
      next_selector = ".next-button"

      session = Capybara::Session.new(:selenium)
      user_agent = session.evaluate_script('navigator.userAgent')
      headers = { "User-Agent" => user_agent }
      session.visit(url)

      # need to number the images in case they don't have sequenced names
      sequence = "00000"
      download_image(session.find(image_selector)["src"], sequence:, headers:)

      while session.has_css?(next_selector) && Integer(sequence, 10) < max_pages
        current_url = session.current_url
        session.find(next_selector).click

        begin
          session.assert_no_current_path(current_url)
        rescue Capybara::ExpectationNotMet
          puts "URL did not change, stopping"
          break
        end

        sequence = sequence.next
        # break if sequence > "00010" # for testing purposes

        download_image(session.find(image_selector)["src"], sequence:, headers:)
      end

      # merge images into a single PDF
      `convert *.jpg comic.pdf`
      # `convert comic.pdf -fill white -colorize 20% comic_light.pdf`
      # `convert -brightness-contrast 20x20 comic.pdf comic_bright.pdf`
      # `pdftoppm -png -gray some.pdf some`
    end

    private

    def download_image(image_url, sequence:, headers:)
      return if processed_urls.include?(image_url)

      filename = "#{sequence}_#{File.basename(image_url)}"

      # ensure multiple images don't have the same name
      # if they do, we'll need to adjust our algorithm
      raise "File already exists: #{filename}" if File.exist?(filename)

      response = HTTP.get(image_url, headers:)

      File.write(filename, response.body)
      File.write(PROCESSED_URLS, "#{image_url}\n", mode: "a")
    end

    def processed_urls
      File.exist?(PROCESSED_URLS) ? File.read(PROCESSED_URLS).split("\n") : []
    end
  end
end
