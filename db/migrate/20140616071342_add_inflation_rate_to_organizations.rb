class AddInflationRateToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :inflation_rate, :float
  end
end
