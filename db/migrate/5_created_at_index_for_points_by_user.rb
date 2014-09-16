class CreatedAtIndexForPointsByUser < ActiveRecord::Migration
  def change
    add_index :scorecard_points, [:user_id, :user_type, :created_at],
      order: {created_at: :asc}
  end
end
