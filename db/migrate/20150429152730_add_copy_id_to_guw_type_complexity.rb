class AddCopyIdToGuwTypeComplexity < ActiveRecord::Migration
  def change
    add_column :guw_guw_type_complexities, :copy_id, :integer
  end
end
