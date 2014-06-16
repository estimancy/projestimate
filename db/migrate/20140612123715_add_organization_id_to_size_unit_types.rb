class AddOrganizationIdToSizeUnitTypes < ActiveRecord::Migration
  def change
    add_column :size_unit_types, :organization_id, :integer
  end
end
