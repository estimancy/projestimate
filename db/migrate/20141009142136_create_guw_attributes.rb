class CreateGuwAttributes < ActiveRecord::Migration
  def change
    create_table :guw_guw_attributes do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
