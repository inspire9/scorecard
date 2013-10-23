class CreatePoints < ActiveRecord::Migration
  def change
    create_table :carmack_points do |table|
      table.string  :context,       null: false
      table.string  :identifier,    null: false
      table.integer :amount,        null: false
      table.string  :user_type,     null: false
      table.integer :user_id,       null: false
      table.string  :gameable_type
      table.integer :gameable_id
      table.timestamps
    end

    add_index :carmack_points, :context
    add_index :carmack_points, :identifier
    add_index :carmack_points, [:user_type, :user_id]
    add_index :carmack_points, [:gameable_type, :gameable_id]
    add_index :carmack_points, [:context, :identifier, :user_type, :user_id],
      unique: true, name: :unique_points
  end
end