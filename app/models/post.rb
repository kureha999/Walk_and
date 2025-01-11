class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :body, presence: true, length: { maximum: 200 }
  validates :image, presence: true, unless: :image_optional?
  validate :image_content_type

  # JPEGまたはPNG形式の画像に対して、幅200px・高さ100px指定
  # ---- 今後サイズが確定したら使う(このままだとerrorが出る?) ----
  # def image_as_thumbnail
  #   # 画像が添付されていて、画像形式が適切であるかチェック
  #   return unless image.attached? && image.content_type.in?(%w[image/jpeg image/png image/gif image/heic])
  #   # 画像が添付されている場合にのみ variant を処理
  #   image.variant(resize_to_fill: [800, 300]).processed
  # end

  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  private

  def image_optional?
    body.blank? # 本文が空でない場合のみ画像を必須にする
  end
end

  # JPEG, PNG, GIF, HEIC以外の形式の場合、エラー
  def image_content_type
    if image.attached? && !image.content_type.in?(%w[image/jpeg image/png image/gif image/heic])
      errors.add(:image, "：対応していないファイル形式です。JPEG, PNG, GIF, HEICのみアップロード可能です。")
    end
  end

# 画像のサイズが1MBを超える場合、エラーを発生
# ---- 画像サイズが大きい場合こちらでmegabyteを調節できるのか？今後調査 ----
# def image_size
#   if image.attached? && image.blob.byte_size > 1.megabytes
#     errors.add(:image, "：1MB以下のファイルをアップロードしてください。")
#   end
# end
