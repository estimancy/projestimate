class AddThreePointsEstimationToGuwModel < ActiveRecord::Migration
  def change
    add_column :guw_guw_models, :three_points_estimation, :boolean
  end
end
