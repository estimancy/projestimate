class AddDescriptionToPbsProjectElements < ActiveRecord::Migration
  def change
    add_column :pbs_project_elements, :description, :text
  end
end
