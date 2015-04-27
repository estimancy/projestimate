class AddCopyIdToGuwComplexity < ActiveRecord::Migration
  def change
    add_column :projects, :copy_id, :integer, after: :copy_number
    add_column :guw_guw_complexities, :copy_id, :integer
  end
end
