class RenameIsTemporaryViewToIsReferenceView < ActiveRecord::Migration
  def change
    remove_column :views, :is_temporary_view
    add_column :views, :is_reference_view, :boolean, after: :pemodule_id
  end
end
