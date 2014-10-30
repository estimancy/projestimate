class AddGuwUnitOfWorkGroupIdToGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :guw_unit_of_work_group_id, :integer
  end
end
