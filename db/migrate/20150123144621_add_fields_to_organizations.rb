class AddFieldsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :limit4, :integer

    add_column :organizations, :limit1_coef, :float
    add_column :organizations, :limit2_coef, :float
    add_column :organizations, :limit3_coef, :float
    add_column :organizations, :limit4_coef, :float

    add_column :organizations, :limit1_unit, :string
    add_column :organizations, :limit2_unit, :string
    add_column :organizations, :limit3_unit, :string
    add_column :organizations, :limit4_unit, :string
  end
end
