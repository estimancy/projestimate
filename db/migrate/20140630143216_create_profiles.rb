class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.text :description
      t.float :cost_per_hour
      t.string   :uuid
      t.integer  :record_status_id
      t.string   :custom_value
      t.integer  :owner_id
      t.text     :change_comment
      t.integer  :reference_id
      t.string   :reference_uuid

      t.timestamps
    end

    add_index "profiles", ["record_status_id"], :name => "index_profiles_on_record_status_id"
    add_index "profiles", ["reference_id"], :name => "index_profiles_on_parent_id"
    add_index "profiles", ["uuid"], :name => "index_profiles_on_uuid", :unique => true
  end
end
