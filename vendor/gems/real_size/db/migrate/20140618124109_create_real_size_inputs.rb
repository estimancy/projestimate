class CreateRealSizeInputs < ActiveRecord::Migration
  def change
    create_table :real_size_inputs do |t|
      t.integer :pbs_project_element_id
      t.integer :module_project_id
      t.integer :size_unit_id
      t.integer :size_unit_type_id
      t.integer :value_id
      t.integer :project_id

      t.timestamps
    end
  end
end
