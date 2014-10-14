class CreateGuwUnitOfWorks < ActiveRecord::Migration
  def change
    create_table :guw_guw_unit_of_works do |t|
      t.string :name
      t.text :comments

      t.integer :low
      t.integer :most_likely
      t.integer :high

      t.integer :result_low
      t.integer :result_most_likely
      t.integer :result_high

      t.integer :guw_type_id

      t.timestamps
    end
  end
end
