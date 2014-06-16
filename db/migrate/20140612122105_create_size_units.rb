class CreateSizeUnits < ActiveRecord::Migration
  def change
    create_table :size_units do |t|
      t.string :name
      t.string :alias
      t.text :description

      t.timestamps
    end
  end
end
