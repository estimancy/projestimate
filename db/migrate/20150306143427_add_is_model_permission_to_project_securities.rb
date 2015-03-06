class AddIsModelPermissionToProjectSecurities < ActiveRecord::Migration
  def change
    add_column :project_securities, :is_model_permission, :boolean, after: :group_id
    add_column :project_securities, :is_estimation_permission, :boolean, after: :is_model_permission
  end
end
