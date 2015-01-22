class AddEnHelpsToFactors < ActiveRecord::Migration
  def change
    add_column :factors, :en_helps, :text

    #Then rename the helps column to fr_helps
    rename_column :factors, :helps, :fr_helps
  end
end
