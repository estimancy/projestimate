class AddWbsActivityIdToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :wbs_activity_id, :integer
  end
end
