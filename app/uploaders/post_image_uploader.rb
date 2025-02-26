class PostImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Rails.env.production?
    storage :fog
  else
    storage :file
  end

  def size_range
    1.byte..6.megabytes
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    ActionController::Base.helpers.asset_path("walk_and.jpg")
  end

  def extension_allowlist
    %w[jpg jpeg gif png heic webp]
  end

  process resize_to_fit: [ 600, 600 ]
  process :convert_to_webp

  def convert_to_webp
    manipulate! do |img|
      img.format "webp"
      img
    end
  end

  def filename
    super.chomp(File.extname(super)) + ".webp" if original_filename.present?
  end
end
