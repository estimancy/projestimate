class CreateGuwWorkUnits < ActiveRecord::Migration
  def change
    create_table :guw_guw_work_units do |t|
      t.string :name
      t.float :value
      t.integer :guw_model_id

      t.timestamps
    end
  end
end
