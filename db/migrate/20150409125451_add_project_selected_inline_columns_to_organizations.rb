class AddProjectSelectedInlineColumnsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :project_selected_columns, :text
    add_column :organizations, :organization_selected_columns, :text
  end
end
