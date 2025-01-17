class RemoveCommentFromEvents < ActiveRecord::Migration[7.2]
  def change
    remove_column :events, :comment, :text
  end
end
