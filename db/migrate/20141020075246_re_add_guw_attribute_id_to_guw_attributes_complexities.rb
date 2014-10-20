class ReAddGuwAttributeIdToGuwAttributesComplexities < ActiveRecord::Migration
  def change
    add_column :guw_guw_attribute_complexities, :guw_attribute_id, :integer
  end
end
