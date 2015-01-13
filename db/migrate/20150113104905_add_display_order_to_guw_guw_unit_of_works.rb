class AddDisplayOrderToGuwGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :display_order, :integer
  end
end
