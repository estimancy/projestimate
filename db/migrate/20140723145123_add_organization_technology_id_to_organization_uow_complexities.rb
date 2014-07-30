class AddOrganizationTechnologyIdToOrganizationUowComplexities < ActiveRecord::Migration
  def change
    add_column :organization_uow_complexities, :organization_technology_id, :integer
  end
end
