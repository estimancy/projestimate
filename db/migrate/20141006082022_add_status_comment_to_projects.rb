class AddStatusCommentToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :status_comment, :text
  end
end
