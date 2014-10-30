class CreateGuwUnitOfWorkGroup < ActiveRecord::Migration
  def change
    create_table :guw_guw_unit_of_work_groups do |t|
      t.string :name
      t.text :comments
      t.integer :module_project_id

      t.timestamps
    end
  end
end
