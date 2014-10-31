class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.string :name
      t.text :description
      t.integer :organization_id

      t.timestamps
    end
  end
end
