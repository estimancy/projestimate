class CreateProjectFields < ActiveRecord::Migration
  def change
    create_table :project_fields do |t|
      t.integer :project_id
      t.integer :field_id
      t.integer :views_widget_id
      t.string :value

      t.timestamps
    end
  end
end
