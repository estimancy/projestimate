class RemoveDeprecatedTables < ActiveRecord::Migration
  def change
    drop_table :factor_translations
    drop_table :labor_categories
    drop_table :labor_categories_project_areas
    drop_table :master_settings
  end
end
