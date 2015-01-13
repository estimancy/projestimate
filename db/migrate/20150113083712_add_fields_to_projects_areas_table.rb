class AddFieldsToProjectsAreasTable < ActiveRecord::Migration
  def change
    add_column :project_areas, :organization_id, :integer
    add_column :project_categories, :organization_id, :integer
    add_column :platform_categories, :organization_id, :integer
    add_column :acquisition_categories, :organization_id, :integer
  end
end
