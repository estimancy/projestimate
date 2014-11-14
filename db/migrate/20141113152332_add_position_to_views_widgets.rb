class AddPositionToViewsWidgets < ActiveRecord::Migration
  def change
    add_column :views_widgets, :position, :integer
  end
end
