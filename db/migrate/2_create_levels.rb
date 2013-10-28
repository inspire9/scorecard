class CreateLevels < ActiveRecord::Migration
  def change
    create_table :scorecard_levels do |table|
      table.integer :amount,        null: false
      table.string  :user_type,     null: false
      table.integer :user_id,       null: false
      table.timestamps
    end

    add_index :scorecard_levels, [:user_type, :user_id], unique: true
  end
end
