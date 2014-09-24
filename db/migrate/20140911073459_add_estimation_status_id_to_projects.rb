class AddEstimationStatusIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :estimation_status_id, :integer, :after => :description
  end
end
