class AddCopyIdToFields < ActiveRecord::Migration
  def change
    add_column :fields, :copy_id, :integer
  end
end
