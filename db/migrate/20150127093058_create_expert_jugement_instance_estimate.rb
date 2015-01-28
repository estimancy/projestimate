class CreateExpertJugementInstanceEstimate < ActiveRecord::Migration
  def change
    create_table :expert_judgement_instance_estimates do |t|
      t.integer :pbs_project_element_id
      t.integer :module_project_id
      t.integer :pe_attribute_id
      t.integer :expert_judgement_instance_id

      t.float :low_input
      t.float :most_likely_input
      t.float :high_input

      t.float :low_output
      t.float :most_likely_output
      t.float :high_output
    end
  end
end
