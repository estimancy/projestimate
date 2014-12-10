class AddShowNameToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :show_name, :boolean
  end
end
