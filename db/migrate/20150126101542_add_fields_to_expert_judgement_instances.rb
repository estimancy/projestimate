class AddFieldsToExpertJudgementInstances < ActiveRecord::Migration
  def change
    add_column :expert_judgement_instances, :description, :text

    add_column :expert_judgement_instances, :cost_output_unit, :string
    add_column :expert_judgement_instances, :effort_output_unit, :string
    add_column :expert_judgement_instances, :size_output_unit, :string

    add_column :expert_judgement_instances, :effort_unit_coefficient, :float
    add_column :expert_judgement_instances, :cost_unit_coefficient, :float

    add_column :expert_judgement_instances, :three_points_estimation, :boolean


    add_column :module_projects, :expert_judgement_instance_id, :integer
  end
end
