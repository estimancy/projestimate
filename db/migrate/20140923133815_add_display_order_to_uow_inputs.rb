class AddDisplayOrderToUowInputs < ActiveRecord::Migration
  def change
    add_column :uow_inputs, :display_order, :integer
  end
end
