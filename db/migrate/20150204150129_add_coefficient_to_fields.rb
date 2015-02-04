class AddCoefficientToFields < ActiveRecord::Migration
  def change
    add_column :fields, :coefficient, :float
  end
end
