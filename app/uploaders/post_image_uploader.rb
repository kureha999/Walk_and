class PostImageUploader < CarrierWave::Uploader::Base
  # 本番運用は終了。Cloudinaryの認証情報が無い環境(開発など)ではローカル保存+MiniMagickでJPEG変換する
  def self.cloudinary?
    ENV["CLOUDINARY_CLOUD_NAME"].present?
  end

  if cloudinary?
    include Cloudinary::CarrierWave
    after :store, :set_cloudinary_asset_id
  else
    include CarrierWave::MiniMagick
    storage :file
    process :auto_orient_and_resize
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

  process convert: "jpg"

  private

  def auto_orient_and_resize
    manipulate! do |img|
      img.auto_orient
      img.resize "1600x1600>"
      img
    end
  end

  def set_cloudinary_asset_id(file)
    Rails.logger.debug "set_cloudinary_asset_id called"
    if model && file.respond_to?(:public_id)
      model.update_column(:cloudinary_asset_id, file.public_id)
    end
  end
end
