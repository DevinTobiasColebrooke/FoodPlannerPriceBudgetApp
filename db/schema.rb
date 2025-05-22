# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_11_033837) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "allergies", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_allergies_on_name", unique: true
  end

  create_table "dietary_pattern_calorie_levels", force: :cascade do |t|
    t.bigint "dietary_pattern_id", null: false
    t.integer "calorie_level", null: false
    t.integer "limit_on_calories_other_uses_kcal_day"
    t.decimal "limit_on_calories_other_uses_percent_day", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dietary_pattern_id", "calorie_level"], name: "unique_dp_calorie_level_entry", unique: true
    t.index ["dietary_pattern_id"], name: "index_dietary_pattern_calorie_levels_on_dietary_pattern_id"
  end

  create_table "dietary_pattern_food_group_recommendations", force: :cascade do |t|
    t.bigint "dietary_pattern_calorie_level_id", null: false
    t.bigint "food_group_id", null: false
    t.decimal "amount_value", precision: 10, scale: 4, null: false
    t.string "amount_frequency", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dietary_pattern_calorie_level_id", "food_group_id"], name: "idx_dp_fg_recs_on_dp_cal_level_and_fg", unique: true
    t.index ["dietary_pattern_calorie_level_id"], name: "idx_dp_fg_recs_on_dp_cal_level_id"
    t.index ["food_group_id"], name: "idx_dp_fg_recs_on_food_group_id"
  end

  create_table "dietary_patterns", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.text "description"
    t.string "source_document_reference", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dietary_patterns_on_name", unique: true
  end

  create_table "dietary_restrictions", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dietary_restrictions_on_name", unique: true
  end

  create_table "dri_values", force: :cascade do |t|
    t.bigint "nutrient_id", null: false
    t.bigint "life_stage_group_id", null: false
    t.string "dri_type", limit: 50, null: false
    t.decimal "value_numeric", precision: 12, scale: 5
    t.string "value_string", limit: 50
    t.string "unit", limit: 50, null: false
    t.string "source_of_goal", limit: 100
    t.text "criterion"
    t.string "footnote_marker", limit: 10
    t.text "notes"
    t.string "source_document_reference", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["life_stage_group_id"], name: "index_dri_values_on_life_stage_group_id"
    t.index ["nutrient_id", "life_stage_group_id", "dri_type"], name: "unique_dri_value_entry", unique: true
    t.index ["nutrient_id"], name: "index_dri_values_on_nutrient_id"
  end

  create_table "eer_additive_components", force: :cascade do |t|
    t.string "component_type", limit: 50, null: false
    t.string "source_table_reference", limit: 100
    t.bigint "life_stage_group_id"
    t.string "sex_filter", limit: 20
    t.integer "age_min_months_filter"
    t.integer "age_max_months_filter"
    t.integer "condition_pregnancy_trimester_filter"
    t.string "condition_pre_pregnancy_bmi_category_filter", limit: 20
    t.string "condition_lactation_period_filter", limit: 20
    t.integer "value_kcal_day", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_type", "life_stage_group_id", "sex_filter", "age_min_months_filter", "age_max_months_filter", "condition_pregnancy_trimester_filter", "condition_pre_pregnancy_bmi_category_filter", "condition_lactation_period_filter"], name: "unique_eer_additive_component_filters", unique: true
    t.index ["life_stage_group_id"], name: "index_eer_additive_components_on_life_stage_group_id"
  end

  create_table "eer_profiles", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "source_table_reference", limit: 100
    t.bigint "life_stage_group_id"
    t.string "sex_filter", limit: 20, null: false
    t.integer "age_min_months_filter"
    t.integer "age_max_months_filter"
    t.string "pal_category_applicable", limit: 50
    t.decimal "coefficient_intercept", precision: 12, scale: 4
    t.decimal "coefficient_age_years", precision: 12, scale: 4
    t.decimal "coefficient_age_months", precision: 12, scale: 4
    t.decimal "coefficient_height_cm", precision: 12, scale: 4
    t.decimal "coefficient_weight_kg", precision: 12, scale: 4
    t.decimal "coefficient_pal_value", precision: 12, scale: 4
    t.decimal "coefficient_gestation_weeks", precision: 12, scale: 4
    t.string "equation_basis", limit: 50, null: false
    t.decimal "standard_error_of_predicted_value_kcal", precision: 10, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["life_stage_group_id"], name: "index_eer_profiles_on_life_stage_group_id"
    t.index ["name"], name: "index_eer_profiles_on_name", unique: true
  end

  create_table "food_groups", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.bigint "parent_food_group_id"
    t.string "default_unit_name", limit: 50, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_food_groups_on_name", unique: true
    t.index ["parent_food_group_id"], name: "index_food_groups_on_parent_food_group_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_goals_on_name", unique: true
  end

  create_table "growth_factors", force: :cascade do |t|
    t.bigint "life_stage_group_id", null: false
    t.decimal "factor_value", precision: 5, scale: 2, null: false
    t.string "source_document_reference", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["life_stage_group_id"], name: "idx_growth_factors_on_life_stage_group_id", unique: true
    t.index ["life_stage_group_id"], name: "index_growth_factors_on_life_stage_group_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "category", limit: 100
    t.string "default_unit", limit: 50
    t.string "fdc_id", limit: 50
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "kitchen_equipments", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_kitchen_equipments_on_name", unique: true
  end

  create_table "life_stage_groups", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.integer "min_age_months", null: false
    t.integer "max_age_months", null: false
    t.string "sex", limit: 20, null: false
    t.string "special_condition", limit: 50
    t.integer "trimester"
    t.string "lactation_period", limit: 20
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_life_stage_groups_on_name", unique: true
  end

  create_table "meal_plan_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "recipe_id", null: false
    t.date "date", null: false
    t.string "meal_type", limit: 50, null: false
    t.boolean "is_prepped", default: false, null: false
    t.text "notes"
    t.integer "number_of_servings_planned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_id"], name: "index_meal_plan_entries_on_recipe_id"
    t.index ["user_id", "date", "meal_type"], name: "index_meal_plan_entries_on_user_id_and_date_and_meal_type", unique: true
    t.index ["user_id"], name: "index_meal_plan_entries_on_user_id"
  end

  create_table "nutrients", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "dri_identifier", limit: 100, null: false
    t.string "category", limit: 100, null: false
    t.string "default_unit", limit: 50, null: false
    t.string "analysis_unit", limit: 50, null: false
    t.decimal "conversion_factor", precision: 12, scale: 6
    t.text "description"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dri_identifier"], name: "index_nutrients_on_dri_identifier", unique: true
  end

  create_table "pal_definitions", force: :cascade do |t|
    t.bigint "life_stage_group_id", null: false
    t.string "pal_category", limit: 50, null: false
    t.decimal "pal_range_min_value", precision: 4, scale: 2, null: false
    t.decimal "pal_range_max_value", precision: 4, scale: 2, null: false
    t.integer "percentile_value"
    t.decimal "pal_value_at_percentile", precision: 4, scale: 2
    t.decimal "coefficient_for_eer_equation", precision: 4, scale: 2
    t.string "source_document_reference", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["life_stage_group_id", "pal_category"], name: "unique_pal_definition_for_lsg_category", unique: true
    t.index ["life_stage_group_id"], name: "index_pal_definitions_on_life_stage_group_id"
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.decimal "quantity", precision: 10, scale: 4, null: false
    t.string "unit", limit: 50, null: false
    t.string "notes", limit: 255
    t.integer "order_in_recipe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id", "ingredient_id", "notes"], name: "unique_recipe_ingredient_instance", unique: true
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipe_nutrition_items", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "nutrient_id", null: false
    t.decimal "value_per_recipe", precision: 12, scale: 5, null: false
    t.string "unit", limit: 50, null: false
    t.decimal "value_per_serving", precision: 12, scale: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nutrient_id"], name: "index_recipe_nutrition_items_on_nutrient_id"
    t.index ["recipe_id", "nutrient_id"], name: "index_recipe_nutrition_items_on_recipe_id_and_nutrient_id", unique: true
    t.index ["recipe_id"], name: "index_recipe_nutrition_items_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.text "description"
    t.string "image_url", limit: 255
    t.integer "prep_time_minutes"
    t.integer "cook_time_minutes"
    t.integer "total_time_minutes"
    t.text "instructions"
    t.string "serving_size_description", limit: 100
    t.integer "number_of_servings", default: 1, null: false
    t.string "source_name", limit: 255
    t.string "source_url", limit: 255
    t.string "difficulty_level", limit: 50
    t.bigint "creator_id"
    t.boolean "is_public", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_recipes_on_creator_id"
  end

  create_table "reference_anthropometries", force: :cascade do |t|
    t.bigint "life_stage_group_id", null: false
    t.decimal "reference_height_cm", precision: 5, scale: 1
    t.decimal "reference_weight_kg", precision: 5, scale: 2
    t.decimal "median_bmi", precision: 4, scale: 1
    t.string "source_document_reference", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["life_stage_group_id"], name: "idx_ref_anthro_on_life_stage_group_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "shopping_list_items", force: :cascade do |t|
    t.bigint "shopping_list_id", null: false
    t.bigint "ingredient_id"
    t.string "custom_item_name", limit: 255
    t.string "quantity_description", limit: 100
    t.decimal "quantity_numeric", precision: 10, scale: 4
    t.string "unit", limit: 50
    t.boolean "is_checked", default: false, null: false
    t.bigint "preferred_store_id"
    t.string "notes", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_shopping_list_items_on_ingredient_id"
    t.index ["preferred_store_id"], name: "index_shopping_list_items_on_preferred_store_id"
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id"
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", limit: 255, default: "My Shopping List", null: false
    t.string "status", limit: 50, default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_shopping_lists_on_user_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "address", limit: 255
    t.string "zip_code", limit: 20
    t.string "store_type", limit: 50
    t.string "logo_url", limit: 255
    t.string "opening_hours", limit: 255
    t.string "delivery_info", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_allergies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "allergy_id", null: false
    t.string "severity", limit: 50
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allergy_id"], name: "index_user_allergies_on_allergy_id"
    t.index ["user_id", "allergy_id"], name: "index_user_allergies_on_user_id_and_allergy_id", unique: true
    t.index ["user_id"], name: "index_user_allergies_on_user_id"
  end

  create_table "user_dietary_restrictions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "dietary_restriction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dietary_restriction_id"], name: "index_user_dietary_restrictions_on_dietary_restriction_id"
    t.index ["user_id", "dietary_restriction_id"], name: "unique_user_dietary_restriction_entry", unique: true
    t.index ["user_id"], name: "index_user_dietary_restrictions_on_user_id"
  end

  create_table "user_goals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "goal_id", null: false
    t.boolean "is_primary", default: false, null: false
    t.text "custom_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["goal_id"], name: "index_user_goals_on_goal_id"
    t.index ["user_id", "goal_id"], name: "index_user_goals_on_user_id_and_goal_id", unique: true
    t.index ["user_id"], name: "index_user_goals_on_user_id"
  end

  create_table "user_kitchen_equipments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "kitchen_equipment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kitchen_equipment_id"], name: "index_user_kitchen_equipments_on_kitchen_equipment_id"
    t.index ["user_id", "kitchen_equipment_id"], name: "unique_user_kitchen_equipment_entry", unique: true
    t.index ["user_id"], name: "index_user_kitchen_equipments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", limit: 255, null: false
    t.string "avatar_url", limit: 255
    t.string "household_size", limit: 50
    t.string "cooking_time_preference", limit: 50
    t.string "meal_difficulty_preference", limit: 50
    t.string "shopping_difficulty_preference", limit: 50
    t.decimal "weekly_budget", precision: 10, scale: 2
    t.boolean "flexible_budget", default: true, null: false
    t.string "location_preference_type", limit: 50
    t.string "zip_code", limit: 20
    t.integer "age_in_months", null: false
    t.string "sex", limit: 20, null: false
    t.decimal "height_cm", precision: 5, scale: 1, null: false
    t.decimal "weight_kg", precision: 5, scale: 2, null: false
    t.string "physical_activity_level", limit: 50, null: false
    t.boolean "is_pregnant", default: false, null: false
    t.integer "pregnancy_trimester"
    t.boolean "is_lactating", default: false, null: false
    t.string "lactation_period", limit: 20
    t.boolean "is_smoker", default: false, null: false
    t.boolean "is_vegetarian_or_vegan", default: false, null: false
    t.datetime "onboarding_completed_at", precision: nil
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "dietary_pattern_calorie_levels", "dietary_patterns"
  add_foreign_key "dietary_pattern_food_group_recommendations", "dietary_pattern_calorie_levels", name: "fk_dp_fg_recs_on_dp_cal_level_id"
  add_foreign_key "dietary_pattern_food_group_recommendations", "food_groups"
  add_foreign_key "dri_values", "life_stage_groups"
  add_foreign_key "dri_values", "nutrients"
  add_foreign_key "eer_additive_components", "life_stage_groups"
  add_foreign_key "eer_profiles", "life_stage_groups"
  add_foreign_key "food_groups", "food_groups", column: "parent_food_group_id"
  add_foreign_key "growth_factors", "life_stage_groups"
  add_foreign_key "meal_plan_entries", "recipes"
  add_foreign_key "meal_plan_entries", "users"
  add_foreign_key "pal_definitions", "life_stage_groups"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipe_nutrition_items", "nutrients"
  add_foreign_key "recipe_nutrition_items", "recipes"
  add_foreign_key "recipes", "users", column: "creator_id"
  add_foreign_key "reference_anthropometries", "life_stage_groups"
  add_foreign_key "sessions", "users"
  add_foreign_key "shopping_list_items", "ingredients"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_list_items", "stores", column: "preferred_store_id"
  add_foreign_key "shopping_lists", "users"
  add_foreign_key "user_allergies", "allergies"
  add_foreign_key "user_allergies", "users"
  add_foreign_key "user_dietary_restrictions", "dietary_restrictions"
  add_foreign_key "user_dietary_restrictions", "users"
  add_foreign_key "user_goals", "goals"
  add_foreign_key "user_goals", "users"
  add_foreign_key "user_kitchen_equipments", "kitchen_equipments"
  add_foreign_key "user_kitchen_equipments", "users"
end
