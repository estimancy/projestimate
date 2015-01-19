class AddOrganizationIdToWorkElementTypes < ActiveRecord::Migration
  def change
    add_column :work_element_types, :organization_id, :integer
  end
end
