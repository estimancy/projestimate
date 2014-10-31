class AddGuwModelIdToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :guw_model_id, :integer
  end
end
