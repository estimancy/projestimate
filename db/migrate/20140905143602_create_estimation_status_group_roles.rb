class CreateEstimationStatusGroupRoles < ActiveRecord::Migration
  def change
    create_table :estimation_status_group_roles do |t|
      t.integer :estimation_status_id
      t.integer :group_id
      t.integer :permission_id
      t.integer :organization_id

      t.timestamps
    end
  end
end
