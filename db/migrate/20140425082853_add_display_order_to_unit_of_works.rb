class AddDisplayOrderToUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :unit_of_works, :display_order, :integer
  end
end
