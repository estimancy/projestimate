class AddMasterFieldsToFactors < ActiveRecord::Migration
  def change
    add_column :factors, :uuid, :string
    add_column :factors, :record_status_id, :integer
    add_column :factors, :custom_value, :string
    add_column :factors, :owner_id, :integer
    add_column :factors, :change_comment, :text
    add_column :factors, :reference_id, :integer
    add_column :factors, :reference_uuid, :string
  end
end
