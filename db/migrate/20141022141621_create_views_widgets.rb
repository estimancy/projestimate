class CreateViewsWidgets < ActiveRecord::Migration
  def change
    create_table :views_widgets do |t|
      t.integer :view_id
      t.integer :widget_id
      t.string :name
      t.integer :module_project_id
      t.integer :pe_attribute_id
      t.integer :pbs_project_element_id
      t.string :icon_class
      t.string :color
      t.string   :position_x
      t.string   :position_y
      t.string   :width
      t.string   :height
      t.string   :widget_type
      t.boolean  :show_min_max

      t.timestamps
    end
  end
end
