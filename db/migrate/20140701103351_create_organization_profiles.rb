class CreateOrganizationProfiles < ActiveRecord::Migration
  def change
    create_table :organization_profiles do |t|
      t.integer :organization_id
      t.string :name
      t.text :description
      t.float :cost_per_hour

      t.timestamps
    end
  end
end
