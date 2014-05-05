class AddSingleEntryAttributeToPeAttributes < ActiveRecord::Migration
  def change
    add_column :pe_attributes, :single_entry_attribute, :boolean
  end
end
