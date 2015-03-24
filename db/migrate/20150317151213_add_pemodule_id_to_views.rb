class AddPemoduleIdToViews < ActiveRecord::Migration
  def change
    add_column :views, :pemodule_id, :integer, after: :organization_id
    add_column :views, :is_default_view, :boolean, after: :pemodule_id
    add_column :views, :is_temporary_view, :boolean, after: :is_default_view
    add_column :views, :initial_view_id, :integer, after: :is_temporary_view


    add_column :views_widgets, :from_initial_view, :boolean
  end
end
