class AddOrganizationIdToProjectSecurityLevels < ActiveRecord::Migration
  def change
    add_column :project_security_levels, :organization_id, :integer
  end
end
