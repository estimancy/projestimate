class AddMasterFieldsToSizeUnitAndSizeUnitType < ActiveRecord::Migration
  def change
    add_column :size_units, :uuid, :string
    add_column :size_units, :record_status_id, :integer
    add_column :size_units, :custom_value, :string
    add_column :size_units, :owner_id, :integer
    add_column :size_units, :change_comment, :text
    add_column :size_units, :reference_id, :integer
    add_column :size_units, :reference_uuid, :string


    add_column :size_unit_types, :uuid, :string
    add_column :size_unit_types, :record_status_id, :integer
    add_column :size_unit_types, :custom_value, :string
    add_column :size_unit_types, :owner_id, :integer
    add_column :size_unit_types, :change_comment, :text
    add_column :size_unit_types, :reference_id, :integer
    add_column :size_unit_types, :reference_uuid, :string
  end
end
