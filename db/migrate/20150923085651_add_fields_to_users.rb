class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :description, :text
    add_column :users, :subscription_end_date, :datetime, :default => (Time.now + 1.year)
  end
end
