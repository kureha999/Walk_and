class Post < ApplicationRecord
  mount_uploader :image, PostImageUploader

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  validates :body, presence: true, length: { maximum: 200 }
  validates :image, presence: true, unless: :image_optional?

  def liked_by?(user)
    return false if user.nil?
    likes.exists?(user_id: user.id)
  end

  private

  def image_optional?
    body.present?
  end
end
