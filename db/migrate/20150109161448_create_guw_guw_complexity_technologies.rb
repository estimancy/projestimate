class CreateGuwGuwComplexityTechnologies < ActiveRecord::Migration
  def up
    create_table :guw_guw_complexity_technologies do |t|
      t.integer :guw_complexity_id
      t.integer :guw_technology_id
      t.float :coefficient

      t.timestamps
    end
  end
end
