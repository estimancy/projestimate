class AddProfileCategoryIdToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :profile_category_id, :integer
    add_column :organization_profiles, :profile_category_id, :integer
  end
end
