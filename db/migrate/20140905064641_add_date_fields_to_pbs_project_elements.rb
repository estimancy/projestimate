class AddDateFieldsToPbsProjectElements < ActiveRecord::Migration
  def change
    add_column :pbs_project_elements, :start_date, :date
    add_column :pbs_project_elements, :end_date, :date
  end
end
