class AddGuwModelIdToGuwUnitOfWorks < ActiveRecord::Migration
  def change
    add_column :guw_guw_unit_of_works, :guw_model_id, :integer
  end
end
