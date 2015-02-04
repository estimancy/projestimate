class AddSizeUnitToGuwModels < ActiveRecord::Migration
  def change
    add_column :ge_ge_models, :size_unit, :string
  end
end
