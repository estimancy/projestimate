class AddCurrencyIdToOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :cost_unit

    add_column :organizations, :currency_id, :integer, :after => :number_hours_per_month
  end
end
