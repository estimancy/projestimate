class AddGuwModelIdToGuwAttributes < ActiveRecord::Migration
  def change
    add_column :guw_guw_attributes, :guw_model_id, :integer
  end
end
