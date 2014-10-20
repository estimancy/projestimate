class CreateGuwTypeComplexities < ActiveRecord::Migration
  def up
    create_table :guw_guw_type_complexities do |t|
      t.string :name
      t.text :description
      t.float :value
      t.integer :guw_type_id
      t.timestamps
    end

    add_column :guw_guw_attribute_complexities, :guw_type_complexity_id, :integer
  end

  def down
    drop_table :guw_guw_type_complexities
    remove_column :guw_guw_attributes_complexities, :guw_type_complexity_id
  end
end
