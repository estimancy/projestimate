class AddGuwModelIdToGuwGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :guw_model_id, :integer
  end
end
