class CreateProfileCategories < ActiveRecord::Migration
  def change
    create_table "profile_categories", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.integer  "organization_id"    # Only needed if profile category is added from the Organization edit view
      t.string   "uuid"
      t.integer  "record_status_id"
      t.string   "custom_value"
      t.integer  "owner_id"
      t.text     "change_comment"
      t.integer  "reference_id"
      t.string   "reference_uuid"

      t.timestamps
    end

  end
end
