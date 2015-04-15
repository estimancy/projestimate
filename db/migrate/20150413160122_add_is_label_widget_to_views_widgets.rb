class AddIsLabelWidgetToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :is_label_widget, :boolean
  end
end
