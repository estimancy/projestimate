class AddFieldToGeGeModels < ActiveRecord::Migration
  def change
    add_column :ge_ge_models, :output_unit, :string
    add_column :ge_ge_models, :three_points_estimation, :boolean
  end
end
