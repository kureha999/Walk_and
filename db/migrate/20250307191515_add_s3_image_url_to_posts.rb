class AddS3ImageUrlToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :s3_image_url, :text
  end
end
