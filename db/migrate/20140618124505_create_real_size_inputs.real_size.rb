# This migration comes from real_size (originally 20140618124109)
class CreateRealSizeInputs < ActiveRecord::Migration
  def change
    create_table :real_size_inputs do |t|
      t.integer :pbs_project_element_id
      t.integer :module_project_id
      t.integer :size_unit_id
      t.integer :size_unit_type_id
      t.integer :project_id
      t.float :value

      t.timestamps
    end
  end
end
