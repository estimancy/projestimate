class AddOriginalModelIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :original_model_id, :integer, after: :organization_id
  end
end
