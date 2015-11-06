class AddFiltersToKbInputs < ActiveRecord::Migration
  def change
    add_column :kb_kb_inputs, :filters, :text
  end
end