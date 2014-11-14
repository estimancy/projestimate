class RemoveOldTables < ActiveRecord::Migration
  def change
    drop_table :events
    drop_table :event_types
    drop_table :labor_categories
    drop_table :organization_labor_categories
  end
end
