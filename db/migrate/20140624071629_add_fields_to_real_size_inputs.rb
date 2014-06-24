class AddFieldsToRealSizeInputs < ActiveRecord::Migration
  def change
    rename_column :real_size_inputs, :value, :value_low
    add_column :real_size_inputs, :value_most_likely, :float
    add_column :real_size_inputs, :value_high, :float
  end
end
