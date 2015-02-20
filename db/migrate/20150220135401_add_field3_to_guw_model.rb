class AddField3ToGuwModel < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :one_level_model, :boolean
  end
end
