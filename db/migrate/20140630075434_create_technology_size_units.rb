class CreateTechnologySizeUnits < ActiveRecord::Migration
  def change
    create_table :technology_size_units do |t|
      t.integer :size_unit_id
      t.integer :organization_technology_id
      t.integer :organization_id
      t.float :value

      t.timestamps
    end
  end
end
