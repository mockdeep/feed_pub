# frozen_string_literal: true

module FeedPub::Run
  class << self
    include FeedPub::Helpers

    DEFAULT_MAX_PAGES = 100

    attr_accessor :processed_urls
    attr_writer :driver

    def driver
      @driver ||= :selenium
    end

    def call(url, file_path:, max_pages: DEFAULT_MAX_PAGES)
      Capybara.predicates_wait = false
      session = Capybara::Session.new(driver)
      session.visit(url)

      raise "No images on page" unless session.has_css?("img", wait: 5)

      image_selector = infer_image_selector(session)
      next_selector = FeedPub::InferNextSelector.call(session)
      self.processed_urls = []

      # need to number the images in case they don't have sequenced names
      sequence = "00000"
      session.all(image_selector).each do |img|
        sequence = download_image(img, referer: url, sequence:, file_path:)
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
          sequence = download_image(img, referer: url, sequence:, file_path:)
        end
      end

      # merge all images (png, jpg, etc.) into a single PDF
      image_list = Magick::ImageList.new(*Dir.glob(File.join(file_path, "*")))
      image_list.write(File.join(file_path, "comic.pdf"))
      # `convert comic.pdf -fill white -colorize 20% comic_light.pdf`
      # `convert -brightness-contrast 20x20 comic.pdf comic_bright.pdf`
      # `pdftoppm -png -gray some.pdf some`
      output.puts "done"
    end

    private

    def infer_image_selector(session)
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

    def download_image(img, referer:, sequence:, file_path:)
      image_url = img["data-url"] || img["src"]
      if processed_urls.include?(image_url)
        output.puts "already downloaded: #{image_url}"
        return sequence
      end

      output.puts "downloading: #{image_url.inspect}"

      filename = "#{sequence}_#{File.basename(image_url)}"
      image_path = File.join(file_path, filename)

      # ensure multiple images don't have the same name
      # if they do, we'll need to adjust our algorithm
      raise "File already exists: #{filename}" if File.exist?(image_path)

      response = HTTP.follow.get(image_url, headers: { Referer: referer })

      image_path = File.join(file_path, filename)
      File.write(image_path, response.body.to_s)
      processed_urls << image_url
      sequence.next
    end
  end
end
