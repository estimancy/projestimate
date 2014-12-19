class AddCopyNumberToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :copy_number, :integer, default: 0
  end
end
