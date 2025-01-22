class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :body, presence: true, length: { maximum: 200 }
  validates :image, presence: true, unless: :image_optional?
  validate :image_content_type

  # いいね機能
  def liked_by?(user)
    return false if user.nil?
    likes.exists?(user_id: user.id)
  end

  # リサイズ用のバリアント(品質90に設定)
  def resized_image
    return unless image.attached?
    image.variant(resize_to_fill: [ 600, 600 ], saver: { quality: 90, interlace: "plane" })
  end

  private

  def image_optional?
    body.blank? # 本文が空でない場合のみ画像を必須にする
  end

  # JPEG, PNG, GIF, HEIC以外の形式の場合、エラー
  def image_content_type
    if image.attached? && !image.content_type.in?(%w[image/jpeg image/png image/gif image/heic])
      errors.add(:image, t("model.post.error.image_content_type"))
    end
  end
end
