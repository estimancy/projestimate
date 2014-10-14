class ChangeAttributesInGuwModels < ActiveRecord::Migration
  def change
    rename_column :guw_guw_models, :organization_technology_id, :organization_id
  end
end
