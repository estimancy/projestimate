class AddEstimationValueIdToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :estimation_value_id, :integer, :after => :module_project_id
  end
end
