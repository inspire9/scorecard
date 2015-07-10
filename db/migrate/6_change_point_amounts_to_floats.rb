class ChangePointAmountsToFloats < ActiveRecord::Migration
  def change
    change_column :scorecard_points, :amount, :decimal, null: false,
      precision: 10
  end
end
