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
    %w[jpg jpeg gif png heic]
  end

  process resize_to_fit: [ 600, 600 ]
  process :convert_heic_to_jpeg, if: :heic?

  private

  def heic?(file)
    file.content_type == "image/heic" || file.extension.downcase == "heic"
  end

  def convert_heic_to_jpeg
    cache_stored_file! unless cached?

    temp_path = current_path.sub(/\.\w+$/, ".jpg")
    image = MiniMagick::Image.open(current_path)
    image.format("jpg")
    image.write(temp_path)
    File.rename(temp_path, current_path.sub(/\.heic\z/i, ".jpg"))
  end
end
