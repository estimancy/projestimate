class AddFieldToExpertJudgementInstanceEstimates < ActiveRecord::Migration
  def change
    add_column :expert_judgement_instance_estimates, :description, :text
    add_column :expert_judgement_instance_estimates, :comments, :text
    add_column :expert_judgement_instance_estimates, :tracking, :text
  end
end
