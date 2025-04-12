# frozen_string_literal: true

module FeedPub::Run
  class << self
    PROCESSED_URLS = "downloaded_images.txt"
    DEFAULT_MAX_PAGES = 100

    def call(url, output:, filepath:, max_pages: DEFAULT_MAX_PAGES)
      session = Capybara::Session.new(:selenium)
      session.visit(url)
      image_selector = infer_image_selector(session, output:)
      next_selector = FeedPub::InferNextSelector.call(session, output:)

      # need to number the images in case they don't have sequenced names
      sequence = "00000"
      session.all(image_selector).each do |img|
        sequence =
          download_image(img, referer: url, sequence:, output:, filepath:)
      end

      while next_selector.matches?(session) && Integer(sequence, 10) < max_pages
        current_url = session.current_url
        output.puts "current url: #{current_url}"
        next_selector.click(session)

        begin
          session.assert_no_current_path(current_url)
          output.puts "new current url: #{current_url}"
        rescue Capybara::ExpectationNotMet
          output.puts "URL did not change, stopping"
          break
        end

        session.all(image_selector).each do |img|
          sequence =
            download_image(img, referer: url, sequence:, output:, filepath:)
        end
      end

      processed_path = File.join(filepath, PROCESSED_URLS)
      File.delete(processed_path)
      # merge all images (png, jpg, etc.) into a single PDF
      `convert * comic.pdf`
      # `convert comic.pdf -fill white -colorize 20% comic_light.pdf`
      # `convert -brightness-contrast 20x20 comic.pdf comic_bright.pdf`
      # `pdftoppm -png -gray some.pdf some`
      output.puts "done"
    end

    private

    def infer_image_selector(session, output:)
      output.puts "inferring image selector"
      # find all elements on the page with "comic" in id or class
      # then find the ones with no children matching the same criteria
      # then find the one with the biggest image
      selector = "[id*='comic'], [class*='comic'], .viewer_img"
      candidates =
        session.all(selector).select do |element|
          element.has_no_css?(selector) && element.has_css?("img")
        end

      element =
        candidates.max_by do |candidate|
          candidate.all("img").map { |img| Integer(img["width"]) }.max
        end

      raise "No image candidates found" unless element

      final_selector =
        if element["id"].present?
          "[id='#{element["id"]}'] img"
        else
          "[class='#{element["class"]}'] img"
        end

      output.puts "final image selector: '#{final_selector}'"

      final_selector
    end

    def download_image(img, referer:, sequence:, output:, filepath:)
      image_url = img["data-url"] || img["src"]
      if processed_urls(filepath:).include?(image_url)
        output.puts "already downloaded: #{image_url}"
        return sequence
      end

      output.puts "downloading: #{image_url.inspect}"

      filename = "#{sequence}_#{File.basename(image_url)}"
      image_path = File.join(filepath, filename)

      # ensure multiple images don't have the same name
      # if they do, we'll need to adjust our algorithm
      raise "File already exists: #{filename}" if File.exist?(image_path)

      response = HTTP.follow.get(image_url, headers: { Referer: referer })

      image_path = File.join(filepath, filename)
      File.write(image_path, response.body.to_s)
      processed_path = File.join(filepath, PROCESSED_URLS)
      File.write(processed_path, "#{image_url}\n", mode: "a")
      sequence.next
    end

    def processed_urls(filepath:)
      processed_path = File.join(filepath, PROCESSED_URLS)

      File.exist?(processed_path) ? File.read(processed_path).split("\n") : []
    end
  end
end
