class RenameFields < ActiveRecord::Migration
  def change
    rename_column :expert_judgement_instances, :size_output_unit, :retained_size_unit
    rename_column :expert_judgement_instances, :effort_output_unit, :effort_unit
    rename_column :expert_judgement_instances, :cost_output_unit, :cost_unit
    rename_column :ge_ge_models, :output_unit, :effort_unit
    rename_column :guw_guw_models, :output_unit, :retained_size_unit
  end
end
