class AddShowWbsActivityRatioToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :show_wbs_activity_ratio, :boolean
  end
end
