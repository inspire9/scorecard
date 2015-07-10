class ChangePointAmountsToFloats < ActiveRecord::Migration
  def up
    change_column :scorecard_points, :amount, :decimal, null: false,
      precision: 10, scale: 6
  end

  def down
    change_column :scorecard_points, :amount, :integer
  end
end
