class AddStandardUnitCoefficientToGeModels < ActiveRecord::Migration
  def change
    add_column :ge_ge_models, :standard_unit_coefficient, :float
  end
end
