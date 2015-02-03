class AddFieldsToWbsActivities < ActiveRecord::Migration
  def change
    add_column :wbs_activities, :three_points_estimation, :boolean
    add_column :wbs_activities, :cost_unit, :string
    add_column :wbs_activities, :cost_unit_coefficient, :float
    add_column :wbs_activities, :effort_unit, :string
    add_column :wbs_activities, :effort_unit_coefficient, :float
  end
end
