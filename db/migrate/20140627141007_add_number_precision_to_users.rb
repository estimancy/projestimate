class AddNumberPrecisionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :number_precision, :integer
  end
end
