class CreateSizeUnitTypes < ActiveRecord::Migration
  def change
    create_table :size_unit_types do |t|
      t.string :name
      t.string :alias
      t.text :description

      t.timestamps
    end
  end
end
