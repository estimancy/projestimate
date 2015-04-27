class AddCopyIdToGuwGuwModels < ActiveRecord::Migration
  def change
    # for instance modules
    add_column :guw_guw_models, :copy_id, :integer
    add_column :ge_ge_models, :copy_id, :integer
    add_column :expert_judgement_instances, :copy_id, :integer
    add_column :wbs_activities, :copy_id, :integer, after: :copy_number
    add_column :guw_guw_types, :copy_id, :integer
    ###add_column :guw_guw_type_complexities, :copy_id, :integer
    add_column :guw_guw_attributes, :copy_id, :integer
    add_column :guw_guw_work_units, :copy_id, :integer
    add_column :organization_technologies, :copy_id, :integer
    add_column :organization_profiles, :copy_id, :integer
    add_column :wbs_activity_ratios, :copy_id, :integer


    #Remove index
    remove_index(:wbs_activities, :name => 'index_wbs_activities_on_uuid')
    remove_index(:wbs_activities, :name => 'index_wbs_activities_on_record_status_id')
    remove_index(:wbs_activities, :name => 'index_wbs_activities_on_reference_id')

    remove_index(:wbs_activity_elements, :name => 'index_wbs_activity_elements_on_uuid')
    remove_index(:wbs_activity_elements, :name => 'index_wbs_activity_elements_on_record_status_id')
    remove_index(:wbs_activity_elements, :name => 'index_wbs_activity_elements_on_reference_id')

    remove_index(:wbs_activity_ratios, :name => 'index_wbs_activity_ratios_on_uuid')
    remove_index(:wbs_activity_ratios, :name => 'index_wbs_activity_ratios_on_record_status_id')
    remove_index(:wbs_activity_ratios, :name => 'index_wbs_activity_ratios_on_reference_id')

    remove_index(:wbs_activity_ratio_elements, :name => 'index_wbs_activity_ratio_elements_on_uuid')
    remove_index(:wbs_activity_ratio_elements, :name => 'index_wbs_activity_ratio_elements_on_record_status_id')
    remove_index(:wbs_activity_ratio_elements, :name => 'index_wbs_activity_ratio_elements_on_reference_id')

  end
end
