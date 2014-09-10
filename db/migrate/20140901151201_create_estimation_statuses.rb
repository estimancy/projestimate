class CreateEstimationStatuses < ActiveRecord::Migration
  def change
    create_table :estimation_statuses do |t|
      t.integer :organization_id
      t.integer :status_number
      t.string  :status_alias
      t.string :name
      t.string :status_color
      t.text :description

      t.timestamps
    end
  end
end
