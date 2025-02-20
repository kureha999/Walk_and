require "mini_magick"
require "stringio"

class ConvertHeicToJpegJob < ApplicationJob
  queue_as :default

  def perform(post)
    return unless post.image.attached?
    return unless post.image.blob.content_type.in?(%w[image/heic image/heif])

    begin
      original_data = post.image.download
      image = MiniMagick::Image.read(original_data, format: "heic")
      image.format("jpg")
      converted_data = StringIO.new(image.to_blob)
      post.image.purge_later
      post.image.attach(
        io: converted_data,
        filename: "converted.jpg",
        content_type: "image/jpeg"
      )
      Rails.logger.info("HEIC to JPEG conversion succeeded for Post ##{post.id}")
    rescue => e
      Rails.logger.error("HEIC to JPEG conversion failed: #{e.message}")
    end
  end
end
