class CreateWbsActivityInput < ActiveRecord::Migration
  def change
    create_table :wbs_activity_inputs do |t|
      t.integer :wbs_activity_ratio_id
      t.integer :wbs_activity_id
      t.integer :module_project_id
      t.integer :pbs_project_element_id
      t.text :comment
    end
  end
end
