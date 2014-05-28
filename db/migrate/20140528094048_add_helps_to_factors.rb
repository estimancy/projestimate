class AddHelpsToFactors < ActiveRecord::Migration
  def change
    add_column :factors, :helps, :text
  end
end
