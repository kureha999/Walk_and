class AddCloudinaryAssetIdToPosts < ActiveRecord::Migration[7.2]
  def change
    add_column :posts, :cloudinary_asset_id, :string
    add_index :posts, :cloudinary_asset_id
  end
end
