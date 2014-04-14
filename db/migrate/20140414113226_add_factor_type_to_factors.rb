class AddFactorTypeToFactors < ActiveRecord::Migration
  def change
    add_column :factors, :factor_type, :string
  end
end
