class AddPbsProjectElementIdToInputs < ActiveRecord::Migration
  def change
    add_column :inputs, :pbs_project_element_id, :integer
  end
end
