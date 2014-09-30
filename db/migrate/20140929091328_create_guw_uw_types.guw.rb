# This migration comes from guw (originally 20140926074335)
class CreateGuwUwTypes < ActiveRecord::Migration
  def change
    create_table :guw_guw_types do |t|
      t.string :name
      t.text :description
      t.integer :organization_technology_id

      t.timestamps
    end
  end
end
