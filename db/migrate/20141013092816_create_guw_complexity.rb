class CreateGuwComplexity < ActiveRecord::Migration
  def change
    create_table :guw_guw_complexities do |t|
      t.string :name
      t.string :alias
      t.integer :weight
      t.integer :bottom_range
      t.integer :top_range
      t.integer :guw_type_id

      t.timestamps
    end
  end
end
