class CreateTechnologySizeType < ActiveRecord::Migration
  def change
    create_table :technology_size_types do |t|
      t.integer :organization_technology_id
      t.integer :size_unit_id
      t.integer :size_unit_type_id
      t.integer :organization_id
      t.float :value

      t.timestamps
    end
  end
end
