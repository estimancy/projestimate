class ChangeTypeOfWeightToGuwComplexities < ActiveRecord::Migration
  def up
    change_column :guw_guw_complexities, :weight, :float
  end

  def down
    change_column :guw_guw_complexities, :weight, :integer
  end
end
