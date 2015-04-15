class AddOffLineUoToGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :off_line_uo, :boolean
  end
end
