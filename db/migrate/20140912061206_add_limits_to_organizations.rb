class AddLimitsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :limit1, :integer
    add_column :organizations, :limit2, :integer
    add_column :organizations, :limit3, :integer
  end
end
