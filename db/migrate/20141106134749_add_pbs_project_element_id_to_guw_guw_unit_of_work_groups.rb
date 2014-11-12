class AddPbsProjectElementIdToGuwGuwUnitOfWorkGroups < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_work_groups, :pbs_project_element_id, :integer
  end
end
