class AddFramworkFieldsToGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :module_project_id, :integer
    add_column :guw_guw_unit_of_works, :pbs_project_element_id, :integer
  end
end
