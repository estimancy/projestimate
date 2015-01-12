class CreateGuwComplexitiesWorkUnits < ActiveRecord::Migration
  def change
    create_table :guw_guw_complexity_work_units do |t|
      t.integer :guw_complexity_id
      t.integer :guw_work_unit_id
      t.float :value

      t.timestamps
    end
  end
end
