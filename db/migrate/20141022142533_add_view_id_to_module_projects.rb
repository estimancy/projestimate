class AddViewIdToModuleProjects < ActiveRecord::Migration
  def change
    add_column :module_projects, :view_id, :integer
    add_column :module_projects, :show_results_view, :boolean, :default => true
    add_column :module_projects, :color, :string
  end
end
