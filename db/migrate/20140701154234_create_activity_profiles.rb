class CreateActivityProfiles < ActiveRecord::Migration
  def change
    create_table :activity_profiles do |t|
      t.integer :project_id
      t.integer :wbs_project_element_id
      t.integer :organization_profile_id
      t.float :ratio_percentage

      t.timestamps
    end

  end
end
