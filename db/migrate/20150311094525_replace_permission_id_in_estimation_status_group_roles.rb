class ReplacePermissionIdInEstimationStatusGroupRoles < ActiveRecord::Migration
  def change
    rename_column :estimation_status_group_roles, :permission_id, :project_security_level_id
  end
end
