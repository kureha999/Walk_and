require "mini_magick"
class Post < ApplicationRecord
  belongs_to :user
  # has_one_attached :image
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :body, presence: true, length: { maximum: 200 }
  validates :image, presence: true, unless: :image_optional?
  # validate :image_content_type

  mount_uploader :image, PostImageUploader

  def liked_by?(user)
    return false if user.nil?
    likes.exists?(user_id: user.id)
  end

  # def resized_image
  #   return unless image.attached?
  #   image.variant(resize_to_fill: [ 600, 600 ], saver: { quality: 90, interlace: "plane" })
  # end

  # def image_content_type
  #   if image.attached? && !image.content_type.in?(%w[image/jpeg image/png image/gif image/heic])
  #     errors.add(:image, I18n.t("model.post.error.image_content_type"))
  #   end
  # end

  private

  def image_optional?
    body.present?
  end
end
