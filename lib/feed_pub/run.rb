# frozen_string_literal: true

module FeedPub::Run
  class << self
    PROCESSED_URLS = "downloaded_images.txt"
    DEFAULT_MAX_PAGES = 50

    def call(url, max_pages: DEFAULT_MAX_PAGES)
      session = Capybara::Session.new(:selenium)
      session.visit(url)
      image_selector = infer_image_selector(session)
      next_selector = infer_next_selector(session)

      # need to number the images in case they don't have sequenced names
      sequence = "00000"
      session.all(image_selector).each do |img|
        download_image(img["src"], sequence:)
        sequence = sequence.next
      end

      while session.has_css?(next_selector) && Integer(sequence, 10) < max_pages
        current_url = session.current_url
        puts "current url: #{current_url}"
        session.first(next_selector).click

        begin
          session.assert_no_current_path(current_url)
          puts "new current url: #{current_url}"
        rescue Capybara::ExpectationNotMet
          puts "URL did not change, stopping"
          break
        end

        session.all(image_selector).each do |img|
          download_image(img["src"], sequence:)
          sequence = sequence.next
        end
      end

      File.delete(PROCESSED_URLS)
      # merge all images (png, jpg, etc.) into a single PDF
      `convert * comic.pdf`
      # `convert comic.pdf -fill white -colorize 20% comic_light.pdf`
      # `convert -brightness-contrast 20x20 comic.pdf comic_bright.pdf`
      # `pdftoppm -png -gray some.pdf some`
      puts "done"
    end

    private

    def infer_image_selector(session)
      puts "inferring image selector"
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

      final_selector =
        if element['id'].present?
          "[id='#{element['id']}'] img"
        else
          "[class='#{element['class']}'] img"
        end

      puts "final image selector: '#{final_selector}'"

      final_selector
    end

    def infer_next_selector(session)
      puts "inferring next selector"
      # find all elements with "next" in id or class or alt
      # return the selector from the first one
      selector = "[id*='next'i], [class*='next'i], [alt*='next'i]"
      element = session.all(selector).first

      raise "No next candidates found" unless element

      final_selector =
        if element['id'].present?
          "[id='#{element['id']}']"
        elsif element['alt'].present?
          "[alt='#{element['alt']}']"
        else
          "[class='#{element['class']}']"
        end

      puts "final next selector: '#{final_selector}'"

      final_selector
    end

    def download_image(image_url, sequence:)
      if processed_urls.include?(image_url)
        puts "already downloaded: #{image_url}"
        return
      end

      puts "downloading: #{image_url.inspect}"

      filename = "#{sequence}_#{File.basename(image_url)}"

      # ensure multiple images don't have the same name
      # if they do, we'll need to adjust our algorithm
      raise "File already exists: #{filename}" if File.exist?(filename)

      response = HTTP.follow.get(image_url)

      File.write(filename, response.body)
      File.write(PROCESSED_URLS, "#{image_url}\n", mode: "a")
    end

    def processed_urls
      File.exist?(PROCESSED_URLS) ? File.read(PROCESSED_URLS).split("\n") : []
    end
  end
end
