class RenameInputs < ActiveRecord::Migration
  def self.up
    rename_table :inputs, :uow_inputs
  end
  def self.down
    rename_table :uow_inputs, :inputs
  end
end
