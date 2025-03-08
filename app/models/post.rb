class Post < ApplicationRecord
  mount_uploader :image, PostImageUploader

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  validates :body, presence: true, length: { maximum: 200 }
  validates :image, presence: true, unless: :image_optional?

  after_save :update_cloudinary_asset_id
  after_destroy :delete_image_from_cloudinary_and_s3

  def liked_by?(user)
    return false if user.nil?
    likes.exists?(user_id: user.id)
  end

  private

  def image_optional?
    body.present?
  end

  def update_cloudinary_asset_id
    if self.image.present? && self.image.file.respond_to?(:public_id) && self.cloudinary_asset_id.blank?
      self.update_column(:cloudinary_asset_id, self.image.file.public_id)
    end
  end

  def delete_image_from_cloudinary_and_s3
    if self.cloudinary_asset_id.present?
      begin
        Cloudinary::Uploader.destroy(self.cloudinary_asset_id)
      rescue => e
        Rails.logger.error "Failed to delete image from Cloudinary: #{e.message}"
      end
    end


    if self.s3_image_url.present?
      begin
        s3 = Aws::S3::Resource.new(
          region: "ap-northeast-1",
          access_key_id: ENV["AWS_ACCESS_KEY_ID"],
          secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
        )
        uri = URI.parse(self.s3_image_url)
        bucket_name = uri.host.split(".").first
        object_key = uri.path[1..-1]
        bucket = s3.bucket(bucket_name)
        obj = bucket.object(object_key)
        obj.delete
      rescue => e
        Rails.logger.error "Failed to delete image from S3: #{e.message}"
      end
    end
  end
end
