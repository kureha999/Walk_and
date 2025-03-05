class PostImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave
  after :cache, :set_cloudinary_asset_id

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
  process convert: "jpg"

  private

  # Cloudinaryのasset_idをPostモデルに保存
  def set_cloudinary_asset_id(file)
    Rails.logger.debug "set_cloudinary_asset_id called" # ログを追加
    if model && file.respond_to?(:public_id)
      model.update_column(:cloudinary_asset_id, file.public_id)
    end
  end
end
