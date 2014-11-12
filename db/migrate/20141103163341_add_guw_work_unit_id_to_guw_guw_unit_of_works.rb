class AddGuwWorkUnitIdToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :guw_work_unit_id, :integer
  end
end