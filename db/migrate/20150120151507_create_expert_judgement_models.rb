class CreateExpertJudgementModels < ActiveRecord::Migration
  def change
    create_table :expert_judgement_instances do |t|
      t.string :name
      t.integer :organization_id
    end
  end
end
