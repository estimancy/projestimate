class AddOrganizationTechnologyIdToPbsProjectElements < ActiveRecord::Migration
  def change
    add_column :pbs_project_elements, :organization_technology_id, :integer
  end
end
