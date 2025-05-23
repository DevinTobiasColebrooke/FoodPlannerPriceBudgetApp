class RemoveNotNullConstraintsFromCsvTables < ActiveRecord::Migration[8.0]
  def change
    # Nutrients table
    change_column_null :nutrients, :name, true
    change_column_null :nutrients, :dri_identifier, true
    change_column_null :nutrients, :category, true
    change_column_null :nutrients, :default_unit, true
    change_column_null :nutrients, :analysis_unit, true

    # Life Stage Groups table
    change_column_null :life_stage_groups, :name, true
    change_column_null :life_stage_groups, :min_age_months, true
    change_column_null :life_stage_groups, :max_age_months, true
    change_column_null :life_stage_groups, :sex, true

    # Food Groups table
    change_column_null :food_groups, :name, true
    change_column_null :food_groups, :default_unit_name, true

    # Dietary Patterns table
    change_column_null :dietary_patterns, :name, true

    # EER Profiles table
    change_column_null :eer_profiles, :name, true
    change_column_null :eer_profiles, :sex_filter, true

    # EER Additive Components table
    change_column_null :eer_additive_components, :component_type, true
    change_column_null :eer_additive_components, :value_kcal_day, true

    # Growth Factors table
    change_column_null :growth_factors, :life_stage_group_id, true
    change_column_null :growth_factors, :factor_value, true

    # PAL Definitions table
    change_column_null :pal_definitions, :life_stage_group_id, true
    change_column_null :pal_definitions, :pal_category, true

    # Reference Anthropometries table
    change_column_null :reference_anthropometries, :life_stage_group_id, true

    # DRI Values table
    change_column_null :dri_values, :nutrient_id, true
    change_column_null :dri_values, :life_stage_group_id, true
    change_column_null :dri_values, :dri_type, true
    change_column_null :dri_values, :unit, true

    # Dietary Pattern Calorie Levels table
    change_column_null :dietary_pattern_calorie_levels, :dietary_pattern_id, true
    change_column_null :dietary_pattern_calorie_levels, :calorie_level, true

    # Dietary Pattern Food Group Recommendations table
    change_column_null :dietary_pattern_food_group_recommendations, :dietary_pattern_calorie_level_id, true
    change_column_null :dietary_pattern_food_group_recommendations, :food_group_id, true
    change_column_null :dietary_pattern_food_group_recommendations, :amount_value, true
    change_column_null :dietary_pattern_food_group_recommendations, :amount_frequency, true
  end
end
