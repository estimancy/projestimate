class AddDisabledInputToEstimationModels < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :enabled_input, :boolean
    add_column :expert_judgement_instances, :enabled_input, :boolean
    add_column :wbs_activities, :enabled_input, :boolean
  end
end
