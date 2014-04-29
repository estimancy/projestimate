class AddNotesToEstimationValues < ActiveRecord::Migration
  def change
    add_column :estimation_values, :notes, :text
  end
end
