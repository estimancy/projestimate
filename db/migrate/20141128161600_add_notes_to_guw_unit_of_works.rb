class AddNotesToGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_work_groups, :notes, :string
  end
end
