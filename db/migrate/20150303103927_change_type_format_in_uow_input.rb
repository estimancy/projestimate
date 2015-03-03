class ChangeTypeFormatInUowInput < ActiveRecord::Migration
  def up
    change_column :uow_inputs, :size_low, :float
    change_column :uow_inputs, :size_most_likely, :float
    change_column :uow_inputs, :size_high, :float

    change_column :uow_inputs, :gross_low, :float
    change_column :uow_inputs, :gross_most_likely, :float
    change_column :uow_inputs, :gross_high, :float

    change_column :uow_inputs, :weight, :float
  end

  def down
  end
end
