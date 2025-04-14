# frozen_string_literal: true

module FileHelpers
  def root_path
    File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
  end

  def fixture_path
    File.join(root_path, "spec", "fixtures")
  end

  def file_path
    FeedPub::Configuration.file_path
  end

  def tempfiles
    Dir.glob(File.join(file_path, "*"))
  end

  def tempfile_names
    tempfiles.map { |f| File.basename(f) }
  end

  def sketch
    File.read(File.join(fixture_path, "sketch.jpg"))
  end
end
