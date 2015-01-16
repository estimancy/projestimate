class ChangeColumnNameComplexityTechnologies < ActiveRecord::Migration
  def up
    rename_column :guw_guw_complexity_technologies, :guw_technology_id, :organization_technology_id
  end

  def down
    rename_column :guw_guw_complexity_technologies, :organization_technology_id, :guw_technology_id
  end
end
