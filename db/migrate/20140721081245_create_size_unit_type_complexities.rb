class CreateSizeUnitTypeComplexities < ActiveRecord::Migration
  def change
    create_table :size_unit_type_complexities do |t|
      t.integer :size_unit_type_id
      t.integer :organization_uow_complexity_id
      t.float :value

      t.timestamps
    end
  end
end
