class CreateAmoaModels < ActiveRecord::Migration
  def up
    create_table :amoa_amoa_models do |t|
      t.string :name
      t.float :three_points_estimation
      t.integer :organization_id
    end

    create_table :amoa_amoa_applications do |t|
      t.string :name
      t.integer :amoa_model_id
    end

    create_table :amoa_amoa_contexts do |t|
      t.string :name
      t.float :weight
      t.integer :amoa_application_id
      t.integer :amoa_amoa_context_type_id
    end

    create_table :amoa_amoa_context_types do |t|
      t.string :name
    end

    create_table :amoa_amoa_services do |t|
      t.string :name
    end

    create_table :amoa_amoa_criterias do |t|
      t.string :name
    end

    create_table :amoa_amoa_criteria_services do |t|
      t.integer :amoa_amoa_criteria_id
      t.integer :amoa_amoa_service_id
      t.float :weight
    end

    create_table :amoa_amoa_unit_of_works do |t|
      t.string :name
      t.string :description
      t.string :tracability
      t.float :result
      t.integer :amoa_amoa_service_id
    end

    create_table :amoa_amoa_criteria_unit_of_works do |t|
      t.integer :amoa_amoa_criteria_id
      t.integer :amoa_amoa_unit_of_work_id
      t.integer :quantity
    end

    create_table :amoa_amoa_weightings_unit_of_works do |t|
      t.integer :amoa_amoa_weighting_id
      t.integer :amoa_amoa_unit_of_work_id
    end

    create_table :amoa_amoa_weightings do |t|
      t.string :name
      t.float :weight
      t.integer :amoa_amoa_service_id
    end

  end

  def down
    drop_table :amoa_amoa_models
    drop_table :amoa_amoa_applications
    drop_table :amoa_amoa_contexts
    drop_table :amoa_amoa_context_types
    drop_table :amoa_amoa_services
    drop_table :amoa_amoa_criterias
    drop_table :amoa_amoa_criteria_services
    drop_table :amoa_amoa_unit_of_works
    drop_table :amoa_amoa_criteria_unit_of_works
    drop_table :amoa_amoa_weightings_unit_of_works
    drop_table :amoa_amoa_weightings
  end
end
