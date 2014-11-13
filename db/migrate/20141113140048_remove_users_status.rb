class RemoveUsersStatus < ActiveRecord::Migration
  def change
    remove_column :users, :user_status
  end
end
