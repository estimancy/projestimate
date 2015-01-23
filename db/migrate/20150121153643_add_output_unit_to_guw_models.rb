class AddOutputUnitToGuwModels < ActiveRecord::Migration
  def change
      add_column :guw_guw_models, :output_unit, :string
  end
end
