class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.string :name
      t.string :icon_class
      t.string :color
      t.integer :pe_attribute_id
      t.string   :width
      t.string   :height
      t.string  :widget_type

      t.timestamps
    end
  end
end
