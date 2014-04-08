class AddFieldsToOrganizationUowComplexities < ActiveRecord::Migration
  def change
    add_column :organization_uow_complexities, :uuid, :string
    add_column :organization_uow_complexities, :record_status_id, :integer
    add_column :organization_uow_complexities, :custom_value, :string
    add_column :organization_uow_complexities, :owner_id, :integer
    add_column :organization_uow_complexities, :change_comment, :text
    add_column :organization_uow_complexities, :reference_id, :integer
    add_column :organization_uow_complexities, :reference_uuid, :string
  end
end
