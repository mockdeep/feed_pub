# frozen_string_literal: true

module FileHelpers
  def root_path
    File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
  end

  def fixture_path
    File.join(root_path, "spec", "fixtures")
  end

  def temp_files
    Dir.glob("*", base: file_path)
  end

  def image_files
    Dir.glob("*", base: images_path)
  end

  def sketch
    File.read(File.join(fixture_path, "sketch.jpg"))
  end
end
