class CreateUserStates < ActiveRecord::Migration[7.2]
  def change
    create_table :user_states do |t|
      t.references :user, null: false, foreign_key: true
      t.string :state

      t.timestamps
    end
  end
end
