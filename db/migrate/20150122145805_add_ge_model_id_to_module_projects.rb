class AddGeModelIdToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :ge_model_id, :integer
  end
end
