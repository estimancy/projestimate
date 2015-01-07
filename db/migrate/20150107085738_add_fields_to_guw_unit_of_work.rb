class AddFieldsToGuwUnitOfWork < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :tracking, :text
    add_column :guw_guw_unit_of_works, :off_line, :boolean
    add_column :guw_guw_unit_of_works, :selected, :boolean
    add_column :guw_guw_unit_of_works, :flagged, :boolean
  end
end
