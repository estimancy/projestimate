class AddNotesToInputCocomos < ActiveRecord::Migration
  def change
    add_column :input_cocomos, :notes, :text
  end
end
