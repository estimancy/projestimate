class DeleteProfileCategories < ActiveRecord::Migration
  def change
    drop_table :profile_categories

    remove_column :profiles, :profile_category_id
    remove_column :organization_profiles, :profile_category_id
  end
end
