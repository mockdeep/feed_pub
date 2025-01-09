# frozen_string_literal: true

module FeedPub::Run
  class << self
    PROCESSED_URLS = "downloaded_images.txt"
    DEFAULT_MAX_PAGES = 200

    def call(url, max_pages: DEFAULT_MAX_PAGES)
      session = Capybara::Session.new(:selenium)
      session.visit(url)
      image_selector = infer_image_selector(session)
      next_selector = infer_next_selector(session)
      puts "Image selector: '#{image_selector}', Next selector: '#{next_selector}'"
      user_agent = session.evaluate_script('navigator.userAgent')
      headers = { "User-Agent" => user_agent }

      # need to number the images in case they don't have sequenced names
      sequence = "00000"
      download_image(session.find(image_selector)["src"], sequence:, headers:)

      while session.has_css?(next_selector) && Integer(sequence, 10) < max_pages
        current_url = session.current_url
        session.first(next_selector).click

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

    def infer_image_selector(session)
      # find all elements on the page with "comic" in id or class
      # then find the ones with no children matching the same criteria
      # then find the one with the biggest image
      selector = "[id*='comic'i], [class*='comic'i]"
      candidates = session.all(selector).select do |element|
        element.has_no_css?(selector) && element.has_css?("img")
      end

      element = candidates.max_by do |candidate|
        candidate.all("img").map { |img| Integer(img["width"]) }.max
      end

      raise "No image candidates found" unless element

      if element['id'].present?
        "[id='#{element['id']}'] img"
      else
        "[class='#{element['class']}'] img"
      end
    end

    def infer_next_selector(session)
      # find all elements with "next" in id or class or alt
      # return the selector from the first one
      selector = "[id*='next'i], [class*='next'i], [alt*='next'i]"
      element = session.all(selector).first

      raise "No next candidates found" unless element

      if element['id'].present?
        "[id='#{element['id']}']"
      elsif element['class'].present?
        "[class='#{element['class']}']"
      else
        "[alt='#{element['alt']}']"
      end
    end

    def download_image(image_url, sequence:, headers:)
      return if processed_urls.include?(image_url)

      filename = "#{sequence}_#{File.basename(image_url)}"

      # ensure multiple images don't have the same name
      # if they do, we'll need to adjust our algorithm
      raise "File already exists: #{filename}" if File.exist?(filename)

      response = HTTP.follow.get(image_url, headers:)

      File.write(filename, response.body)
      File.write(PROCESSED_URLS, "#{image_url}\n", mode: "a")
    end

    def processed_urls
      File.exist?(PROCESSED_URLS) ? File.read(PROCESSED_URLS).split("\n") : []
    end
  end
end
