# This migration comes from guw (originally 20140926074306)
class CreateGuwUwModels < ActiveRecord::Migration
  def change
    create_table :guw_guw_models do |t|
      t.string :name
      t.text :description
      t.integer :organization_technology_id

      t.timestamps
    end
  end
end
