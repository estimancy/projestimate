class AddIsDefaultToOrganizationUowComplexities < ActiveRecord::Migration
  def change
    add_column :organization_uow_complexities, :is_default, :boolean, default: false
  end
end
