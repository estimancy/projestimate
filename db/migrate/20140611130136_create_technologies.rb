class CreateTechnologies < ActiveRecord::Migration
  def change
    create_table :technologies do |t|
      t.string :name
      t.text :description

      t.string :uuid
      t.integer :record_status_id
      t.string :custom_value
      t.integer :owner_id
      t.text :change_comment
      t.integer :reference_id
      t.string :reference_uuid

      t.timestamps
    end
  end
end
