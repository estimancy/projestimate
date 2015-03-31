class AddCopyIdToEstimationStatuses < ActiveRecord::Migration
  def change
    add_column :estimation_statuses, :copy_id, :integer
    add_column :groups, :copy_id, :integer
    add_column :project_security_levels, :copy_id, :integer
  end
end
