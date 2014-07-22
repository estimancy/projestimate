class AddSizeUnitTypeIdToInputs < ActiveRecord::Migration
  def change
    add_column :inputs, :size_unit_type_id, :integer
  end
end
