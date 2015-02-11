class AddEnabledFieldsToExpertJudgementInstances < ActiveRecord::Migration
  def change
    add_column :expert_judgement_instances, :enabled_cost, :boolean
    add_column :expert_judgement_instances, :enabled_effort, :boolean
    add_column :expert_judgement_instances, :enabled_size, :boolean
  end
end
