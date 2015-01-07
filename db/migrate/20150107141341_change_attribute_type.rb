class ChangeAttributeType < ActiveRecord::Migration
  def up
    change_column :guw_guw_unit_of_works, :result_low, :float
    change_column :guw_guw_unit_of_works, :result_most_likely, :float
    change_column :guw_guw_unit_of_works, :result_high, :float
  end

  def down
    change_column :guw_guw_unit_of_works, :result_low, :integer
    change_column :guw_guw_unit_of_works, :result_most_likely, :integer
    change_column :guw_guw_unit_of_works, :result_high, :integer
  end
end
