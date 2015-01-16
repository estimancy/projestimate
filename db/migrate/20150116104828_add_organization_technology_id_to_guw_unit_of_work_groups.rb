class AddOrganizationTechnologyIdToGuwUnitOfWorkGroups < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_work_groups, :organization_technology_id, :integer
    add_column :guw_guw_unit_of_works, :organization_technology_id, :integer
  end
end
