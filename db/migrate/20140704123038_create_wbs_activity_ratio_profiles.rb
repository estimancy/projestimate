class CreateWbsActivityRatioProfiles < ActiveRecord::Migration
  def change
    create_table :wbs_activity_ratio_profiles do |t|
      t.integer :wbs_activity_ratio_element_id
      t.integer :organization_profile_id
      t.float :ratio_value

      t.timestamps
    end
  end
end
