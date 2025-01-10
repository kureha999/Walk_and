class ChangeBodyInComments < ActiveRecord::Migration[7.2]
  def change
    change_column :comments, :body, :text, null: false
  end
end
