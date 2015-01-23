class CreateGeModels < ActiveRecord::Migration
  def change
    create_table :ge_ge_models do |t|
      t.string :name
      t.float :coeff_a
      t.float :coeff_b
      t.integer :organization_id
    end
  end
end
