class CreateGuwAttributeComplexity < ActiveRecord::Migration
  def change
    create_table :guw_guw_attribute_complexities do |t|
      t.string :name
      t.integer :bottom_range
      t.integer :top_range
      t.float :value
      t.integer :guw_attribute_id
      t.integer :guw_type_id

      t.timestamps
    end
  end
end
