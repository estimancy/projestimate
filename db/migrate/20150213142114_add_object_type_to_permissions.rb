class AddObjectTypeToPermissions < ActiveRecord::Migration
  def change
    add_column :permissions, :object_type, :string
  end
end
