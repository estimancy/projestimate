class AddFields4ToGuwTypes < ActiveRecord::Migration
  def change
    add_column :guw_guw_types, :allow_criteria, :boolean
  end
end
