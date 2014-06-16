class AddIsoCodeToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :iso_code, :string, :after => :description
    add_column :currencies, :iso_code_number, :string, :after => :iso_code
    add_column :currencies, :sign, :string, :after => :iso_code_number
    add_column :currencies, :conversion_rate, :float, :after => :sign
  end
end
