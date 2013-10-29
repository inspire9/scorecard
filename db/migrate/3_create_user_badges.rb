class CreateUserBadges < ActiveRecord::Migration
  def change
    create_table :scorecard_user_badges do |table|
      table.string  :badge,         null: false
      table.string  :identifier,    null: false
      table.string  :user_type,     null: false
      table.integer :user_id,       null: false
      table.string  :gameable_type
      table.integer :gameable_id
      table.timestamps
    end

    add_index :scorecard_user_badges, :badge
    add_index :scorecard_user_badges, :identifier
    add_index :scorecard_user_badges, [:user_type, :user_id]
    add_index :scorecard_user_badges, [:gameable_type, :gameable_id]
    add_index :scorecard_user_badges,
      [:badge, :identifier, :user_type, :user_id],
      unique: true, name: :unique_badges
  end
end
