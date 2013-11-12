class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :scorecard_progresses do |table|
      table.string  :identifier,    null: false
      table.string  :user_type,     null: false
      table.integer :user_id,       null: false
      table.timestamps
    end

    add_index :scorecard_progresses, :identifier
    add_index :scorecard_progresses, [:user_type, :user_id]
    add_index :scorecard_progresses, [:identifier, :user_type, :user_id],
      unique: true, name: :unique_progresses
  end
end
