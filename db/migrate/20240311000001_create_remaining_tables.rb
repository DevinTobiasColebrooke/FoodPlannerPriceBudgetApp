class CreateRemainingTables < ActiveRecord::Migration[7.0]
  def change
    # 2. goals table
    create_table :goals do |t|
      t.string :name, limit: 100, null: false
      t.text :description
      t.timestamps null: false
    end
    add_index :goals, :name, unique: true

    # 3. user_goals table
    create_table :user_goals do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :goal, null: false, foreign_key: true, type: :bigint
      t.boolean :is_primary, null: false, default: false
      t.text :custom_details
      t.timestamps null: false
    end
    add_index :user_goals, [:user_id, :goal_id], unique: true

    # 4. allergies table
    create_table :allergies do |t|
      t.string :name, limit: 100, null: false
      t.timestamps null: false
    end
    add_index :allergies, :name, unique: true

    # 5. user_allergies table
    create_table :user_allergies do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :allergy, null: false, foreign_key: true, type: :bigint
      t.string :severity, limit: 50
      t.text :notes
      t.timestamps null: false
    end
    add_index :user_allergies, [:user_id, :allergy_id], unique: true

    # 6. dietary_restrictions table
    create_table :dietary_restrictions do |t|
      t.string :name, limit: 100, null: false
      t.text :description
      t.timestamps null: false
    end
    add_index :dietary_restrictions, :name, unique: true

    # 7. user_dietary_restrictions table
    create_table :user_dietary_restrictions do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :dietary_restriction, null: false, foreign_key: true, type: :bigint
      t.timestamps null: false
    end
    add_index :user_dietary_restrictions, [:user_id, :dietary_restriction_id], unique: true, name: 'unique_user_dietary_restriction_entry'

    # 8. kitchen_equipments table
    create_table :kitchen_equipments do |t|
      t.string :name, limit: 100, null: false
      t.timestamps null: false
    end
    add_index :kitchen_equipments, :name, unique: true

    # 9. user_kitchen_equipments table
    create_table :user_kitchen_equipments do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :kitchen_equipment, null: false, foreign_key: true, type: :bigint
      t.timestamps null: false
    end
    add_index :user_kitchen_equipments, [:user_id, :kitchen_equipment_id], unique: true, name: 'unique_user_kitchen_equipment_entry'

    # 10. recipes table
    create_table :recipes do |t|
      t.string :name, limit: 255, null: false
      t.text :description
      t.string :image_url, limit: 255
      t.integer :prep_time_minutes
      t.integer :cook_time_minutes
      t.integer :total_time_minutes
      t.text :instructions
      t.string :serving_size_description, limit: 100
      t.integer :number_of_servings, null: false, default: 1
      t.string :source_name, limit: 255
      t.string :source_url, limit: 255
      t.string :difficulty_level, limit: 50
      t.references :creator, foreign_key: { to_table: :users }, type: :bigint
      t.boolean :is_public, null: false, default: false
      t.timestamps null: false
    end

    # 11. ingredients table
    create_table :ingredients do |t|
      t.string :name, limit: 255, null: false
      t.string :category, limit: 100
      t.string :default_unit, limit: 50
      t.string :fdc_id, limit: 50
      t.text :notes
      t.timestamps null: false
    end
    add_index :ingredients, :name, unique: true

    # 12. recipe_ingredients table
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true, type: :bigint
      t.references :ingredient, null: false, foreign_key: true, type: :bigint
      t.decimal :quantity, precision: 10, scale: 4, null: false
      t.string :unit, limit: 50, null: false
      t.string :notes, limit: 255
      t.integer :order_in_recipe
      t.timestamps null: false
    end
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id, :notes], unique: true, name: 'unique_recipe_ingredient_instance'

    # 13. nutrients table
    create_table :nutrients do |t|
      t.string :name, limit: 255, null: false
      t.string :dri_identifier, limit: 100, null: false
      t.string :category, limit: 100, null: false
      t.string :default_unit, limit: 50, null: false
      t.string :analysis_unit, limit: 50, null: false
      t.decimal :conversion_factor, precision: 12, scale: 6
      t.text :description
      t.integer :sort_order
      t.timestamps null: false
    end
    add_index :nutrients, :dri_identifier, unique: true

    # 14. recipe_nutrition_items table
    create_table :recipe_nutrition_items do |t|
      t.references :recipe, null: false, foreign_key: true, type: :bigint
      t.references :nutrient, null: false, foreign_key: true, type: :bigint
      t.decimal :value_per_recipe, precision: 12, scale: 5, null: false
      t.string :unit, limit: 50, null: false
      t.decimal :value_per_serving, precision: 12, scale: 5, null: false
      t.timestamps null: false
    end
    add_index :recipe_nutrition_items, [:recipe_id, :nutrient_id], unique: true

    # 15. life_stage_groups table
    create_table :life_stage_groups do |t|
      t.string :name, limit: 255, null: false
      t.integer :min_age_months, null: false
      t.integer :max_age_months, null: false
      t.string :sex, limit: 20, null: false
      t.string :special_condition, limit: 50
      t.integer :trimester
      t.string :lactation_period, limit: 20
      t.text :notes
      t.timestamps null: false
    end
    add_index :life_stage_groups, :name, unique: true

    # 16. dri_values table
    create_table :dri_values do |t|
      t.references :nutrient, null: false, foreign_key: true, type: :bigint
      t.references :life_stage_group, null: false, foreign_key: true, type: :bigint
      t.string :dri_type, limit: 50, null: false
      t.decimal :value_numeric, precision: 12, scale: 5
      t.string :value_string, limit: 50
      t.string :unit, limit: 50, null: false
      t.string :source_of_goal, limit: 100
      t.text :criterion
      t.string :footnote_marker, limit: 10
      t.text :notes
      t.string :source_document_reference, limit: 255
      t.timestamps null: false
    end
    add_index :dri_values, [:nutrient_id, :life_stage_group_id, :dri_type], unique: true, name: 'unique_dri_value_entry'

    # 17. meal_plan_entries table
    create_table :meal_plan_entries do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :recipe, null: false, foreign_key: true, type: :bigint
      t.date :date, null: false
      t.string :meal_type, limit: 50, null: false
      t.boolean :is_prepped, null: false, default: false
      t.text :notes
      t.integer :number_of_servings_planned
      t.timestamps null: false
    end
    add_index :meal_plan_entries, [:user_id, :date, :meal_type], unique: true

    # 18. shopping_lists table
    create_table :shopping_lists do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.string :name, limit: 255, null: false, default: 'My Shopping List'
      t.string :status, limit: 50, null: false, default: 'active'
      t.timestamps null: false
    end

    # 20. stores table (create before shopping_list_items)
    create_table :stores do |t|
      t.string :name, limit: 255, null: false
      t.string :address, limit: 255
      t.string :zip_code, limit: 20
      t.string :store_type, limit: 50
      t.string :logo_url, limit: 255
      t.string :opening_hours, limit: 255
      t.string :delivery_info, limit: 255
      t.timestamps null: false
    end

    # 19. shopping_list_items table
    create_table :shopping_list_items do |t|
      t.references :shopping_list, null: false, foreign_key: true, type: :bigint
      t.references :ingredient, foreign_key: true, type: :bigint
      t.string :custom_item_name, limit: 255
      t.string :quantity_description, limit: 100
      t.decimal :quantity_numeric, precision: 10, scale: 4
      t.string :unit, limit: 50
      t.boolean :is_checked, null: false, default: false
      t.references :preferred_store, foreign_key: { to_table: :stores }, type: :bigint
      t.string :notes, limit: 255
      t.timestamps null: false
    end

    # 21. dietary_patterns table
    create_table :dietary_patterns do |t|
      t.string :name, limit: 255, null: false
      t.text :description
      t.string :source_document_reference, limit: 255
      t.timestamps null: false
    end
    add_index :dietary_patterns, :name, unique: true

    # 22. food_groups table
    create_table :food_groups do |t|
      t.string :name, limit: 100, null: false
      t.references :parent_food_group, foreign_key: { to_table: :food_groups }, type: :bigint
      t.string :default_unit_name, limit: 50, null: false
      t.text :notes
      t.timestamps null: false
    end
    add_index :food_groups, :name, unique: true

    # 23. dietary_pattern_calorie_levels table
    create_table :dietary_pattern_calorie_levels do |t|
      t.references :dietary_pattern, null: false, foreign_key: true, type: :bigint
      t.integer :calorie_level, null: false
      t.integer :limit_on_calories_other_uses_kcal_day
      t.decimal :limit_on_calories_other_uses_percent_day, precision: 5, scale: 2
      t.timestamps null: false
    end
    add_index :dietary_pattern_calorie_levels, [:dietary_pattern_id, :calorie_level], unique: true, name: 'unique_dp_calorie_level_entry'

    # 24. dietary_pattern_food_group_recommendations table
    create_table :dietary_pattern_food_group_recommendations do |t|
      t.references :dietary_pattern_calorie_level, null: false, foreign_key: { to_table: :dietary_pattern_calorie_levels, name: 'fk_dp_fg_recs_on_dp_cal_level_id' }, type: :bigint, index: { name: 'idx_dp_fg_recs_on_dp_cal_level_id' }
      t.references :food_group, null: false, foreign_key: true, type: :bigint, index: { name: 'idx_dp_fg_recs_on_food_group_id' }
      t.decimal :amount_value, precision: 10, scale: 4, null: false
      t.string :amount_frequency, limit: 10, null: false
      t.timestamps null: false
    end
    add_index :dietary_pattern_food_group_recommendations, [:dietary_pattern_calorie_level_id, :food_group_id], unique: true, name: 'idx_dp_fg_recs_on_dp_cal_level_and_fg'

    # 25. eer_profiles table
    create_table :eer_profiles do |t|
      t.string :name, limit: 255, null: false
      t.string :source_table_reference, limit: 100
      t.references :life_stage_group, foreign_key: true, type: :bigint
      t.string :sex_filter, limit: 20, null: false
      t.integer :age_min_months_filter
      t.integer :age_max_months_filter
      t.string :pal_category_applicable, limit: 50
      t.decimal :coefficient_intercept, precision: 12, scale: 4
      t.decimal :coefficient_age_years, precision: 12, scale: 4
      t.decimal :coefficient_age_months, precision: 12, scale: 4
      t.decimal :coefficient_height_cm, precision: 12, scale: 4
      t.decimal :coefficient_weight_kg, precision: 12, scale: 4
      t.decimal :coefficient_pal_value, precision: 12, scale: 4
      t.decimal :coefficient_gestation_weeks, precision: 12, scale: 4
      t.string :equation_basis, limit: 50, null: false
      t.decimal :standard_error_of_predicted_value_kcal, precision: 10, scale: 2
      t.text :notes
      t.timestamps null: false
    end
    add_index :eer_profiles, :name, unique: true

    # 26. eer_additive_components table
    create_table :eer_additive_components do |t|
      t.string :component_type, limit: 50, null: false
      t.string :source_table_reference, limit: 100
      t.references :life_stage_group, foreign_key: true, type: :bigint
      t.string :sex_filter, limit: 20
      t.integer :age_min_months_filter
      t.integer :age_max_months_filter
      t.integer :condition_pregnancy_trimester_filter
      t.string :condition_pre_pregnancy_bmi_category_filter, limit: 20
      t.string :condition_lactation_period_filter, limit: 20
      t.integer :value_kcal_day, null: false
      t.text :notes
      t.timestamps null: false
    end
    add_index :eer_additive_components,
              [:component_type, :life_stage_group_id, :sex_filter, :age_min_months_filter, :age_max_months_filter, :condition_pregnancy_trimester_filter, :condition_pre_pregnancy_bmi_category_filter, :condition_lactation_period_filter],
              unique: true, name: 'unique_eer_additive_component_filters'

    # 27. reference_anthropometries table
    create_table :reference_anthropometries do |t|
      t.references :life_stage_group, null: false, foreign_key: true, type: :bigint, index: { unique: true, name: 'idx_ref_anthro_on_life_stage_group_id' }
      t.decimal :reference_height_cm, precision: 5, scale: 1
      t.decimal :reference_weight_kg, precision: 5, scale: 2
      t.decimal :median_bmi, precision: 4, scale: 1
      t.string :source_document_reference, limit: 255
      t.timestamps null: false
    end

    # 28. growth_factors table
    create_table :growth_factors do |t|
      t.references :life_stage_group, null: false, foreign_key: true, type: :bigint
      t.decimal :factor_value, precision: 5, scale: 2, null: false
      t.string :source_document_reference, limit: 255
      t.timestamps null: false
    end
    add_index :growth_factors, :life_stage_group_id, unique: true, name: 'idx_growth_factors_on_life_stage_group_id'

    # 29. pal_definitions table
    create_table :pal_definitions do |t|
      t.references :life_stage_group, null: false, foreign_key: true, type: :bigint
      t.string :pal_category, limit: 50, null: false
      t.decimal :pal_range_min_value, precision: 4, scale: 2, null: false
      t.decimal :pal_range_max_value, precision: 4, scale: 2, null: false
      t.integer :percentile_value
      t.decimal :pal_value_at_percentile, precision: 4, scale: 2
      t.decimal :coefficient_for_eer_equation, precision: 4, scale: 2
      t.string :source_document_reference, limit: 255
      t.timestamps null: false
    end
    add_index :pal_definitions, [:life_stage_group_id, :pal_category], unique: true, name: 'unique_pal_definition_for_lsg_category'
  end
end
