require 'csv'

# --- Helper to parse fractional and range values for amounts ---
def parse_amount_value(value_str)
  return nil if value_str.blank?
  value_str = value_str.strip.gsub('"', '') # Remove quotes if any

  if value_str.include?('/') # fraction
    parts = value_str.split(' ')
    total = 0.0
    if parts.length > 1 # mixed number like "1 ¾"
      total += parts[0].to_f
      fraction_part = parts[1]
    else # simple fraction like "⅔"
      fraction_part = parts[0]
    end
    num, den = fraction_part.split('/').map(&:to_f)
    total += num / den if den && den != 0
    return total.round(4)
  elsif value_str.include?('-') # range like "2-3"
    return value_str.split('-').first.to_f.round(4)
  else # simple number
    return value_str.to_f.round(4)
  end
rescue StandardError => e
  puts "WARN: Could not parse amount_value '#{value_str}': #{e.message}. Returning nil."
  nil
end

# --- Helper to find or create/update resources (idempotent) ---
def find_or_create_resource(model_class, find_by_hash, attributes_to_update = {})
  resource = model_class.find_or_initialize_by(find_by_hash)

  merged_attributes = attributes_to_update.merge(find_by_hash)

  sanitized_attributes = {}
  model_column_names = model_class.column_names.map(&:to_sym)
  merged_attributes.each do |key, value|
    sanitized_attributes[key] = value if model_column_names.include?(key)
  end

  begin
    resource.update!(sanitized_attributes)
  rescue ActiveRecord::RecordInvalid => e
    puts "ERROR: Validation failed for #{model_class.name} with find_by_hash: #{find_by_hash} and attributes: #{sanitized_attributes}. Errors: #{e.record.errors.full_messages.join(', ')}"
    raise e
  rescue => e
    puts "ERROR: Could not save #{model_class.name} with find_by_hash: #{find_by_hash} and attributes: #{sanitized_attributes}. Error: #{e.message}"
    raise e
  end
  resource
end

# --- Destruction Order ---
puts "Destroying existing data..."
UserGoal.destroy_all
UserAllergy.destroy_all
UserDietaryRestriction.destroy_all
UserKitchenEquipment.destroy_all
ShoppingListItem.destroy_all
MealPlanEntry.destroy_all
RecipeNutritionItem.destroy_all
RecipeIngredient.destroy_all

DietaryPatternFoodGroupRecommendation.destroy_all
DietaryPatternCalorieLevel.destroy_all
DriValue.destroy_all
GrowthFactor.destroy_all
PalDefinition.destroy_all
ReferenceAnthropometry.destroy_all
EerAdditiveComponent.destroy_all
EerProfile.destroy_all

ShoppingList.destroy_all
Recipe.destroy_all
Ingredient.destroy_all
Store.destroy_all
Session.destroy_all
User.destroy_all

Goal.destroy_all
Allergy.destroy_all
DietaryRestriction.destroy_all
KitchenEquipment.destroy_all

Nutrient.destroy_all
FoodGroup.where.not(parent_food_group_id: nil).destroy_all
FoodGroup.where(parent_food_group_id: nil).destroy_all
DietaryPattern.destroy_all
LifeStageGroup.destroy_all

puts "All specified existing data destroyed."
puts "--------------------------------"

# --- Phase 1: Simple Lookup Table Seeding ---
# ... (Goal, Allergy, KitchenEquipment, DietaryRestriction seeding - unchanged) ...
puts "Seeding Goals..."
[
  { name: "Plan my meals for me", description: "Science based algorithmn plans meals for you, so you don't have to think about meals." },
  { name: "Meet Protein Goals", description: "A timer is set for maximum protein intake." },
  { name: "Weight Loss", description: "Focus on calorie deficit and nutrient-dense foods." },
  { name: "Eat Healthier", description: "Incorporate more whole foods and balanced meals." },
  { name: "Save Money", description: "Budget-friendly recipes and smart shopping." },
  { name: "Learn to Cook", description: "Beginner-friendly recipes and cooking tips." },
  { name: "Meal Prep Efficiency", description: "Recipes suitable for batch cooking and quick assembly." }
].each { |attrs| find_or_create_resource(Goal, { name: attrs[:name] }, attrs.except(:name)) }
puts "Goals seeded: #{Goal.count}"

puts "Seeding Allergies..."
[
  { name: "Dairy" }, { name: "Eggs" }, { name: "Tree Nuts" }, { name: "Peanuts" },
  { name: "Shellfish" }, { name: "Soy" }, { name: "Gluten" }, { name: "Fish" }, { name: "Sesame" }
].each { |attrs| find_or_create_resource(Allergy, { name: attrs[:name] }, attrs.except(:name)) }
puts "Allergies seeded: #{Allergy.count}"

puts "Seeding Kitchen Equipment..."
[
  { name: "Instapot / Pressure Cooker" }, { name: "Blender" }, { name: "Immersion Blender" },
  { name: "Food Processor" }, { name: "Strainer / Colander" }, { name: "Juicer" },
  { name: "Oven" }, { name: "Microwave" }, { name: "Air Fryer" }
].each { |attrs| find_or_create_resource(KitchenEquipment, { name: attrs[:name] }, attrs.except(:name)) }
puts "Kitchen Equipment seeded: #{KitchenEquipment.count}"

puts "Seeding Dietary Restrictions..."
[
  { name: "Vegan", description: "Excludes all animal products and by-products" },
  { name: "Vegetarian", description: "Excludes meat, fish, and poultry" },
  { name: "Low-Carb", description: "Restricts carbohydrate intake" }
].each { |attrs| find_or_create_resource(DietaryRestriction, { name: attrs[:name] }, attrs.except(:name)) }
puts "Dietary Restrictions seeded: #{DietaryRestriction.count}"


# --- Phase 2: Foundational Data from CSVs (Order is CRITICAL) ---
puts "Seeding Foundational Data from CSV files..."

# 1. Nutrients (nutrients.csv)
# ... (unchanged) ...
puts "Seeding Nutrients..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'nutrients.csv'), headers: true, header_converters: :symbol) do |row|
  find_or_create_resource(Nutrient, { dri_identifier: row[:dri_identifier]&.strip }, {
    name: row[:name]&.strip,
    category: row[:category]&.strip,
    default_unit: row[:default_unit]&.strip,
    analysis_unit: row[:analysis_unit]&.strip,
    conversion_factor: row[:conversion_factor].present? ? row[:conversion_factor].to_f : nil,
    description: row[:description].presence,
    sort_order: row[:sort_order].present? ? row[:sort_order].to_i : nil
  })
end
puts "Nutrients seeded: #{Nutrient.count}"

# 2. Life Stages (life_stages.csv -> LifeStageGroup model)
# ... (unchanged) ...
puts "Seeding Life Stage Groups..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'life_stages.csv'), headers: true, header_converters: :symbol) do |row|
  find_or_create_resource(LifeStageGroup, { name: row[:name]&.strip }, {
    min_age_months: row[:min_age_months].to_i,
    max_age_months: row[:max_age_months].present? ? row[:max_age_months].to_i : 1200,
    sex: row[:sex]&.strip,
    special_condition: row[:special_condition].presence&.strip,
    trimester: row[:trimester].present? ? row[:trimester].to_i : nil,
    lactation_period: (row[:lactation_period].present? && row[:lactation_period].strip.length <= 20 ? row[:lactation_period].strip : nil),
    notes: row[:notes].presence
  })
end
puts "Life Stage Groups seeded: #{LifeStageGroup.count}"


# 3. Food Groups (food_groups.csv & food_subgroups.csv for FoodGroup model)
# ... (unchanged - ensure "Meats, Poultry, Eggs" is added to food_subgroups.csv) ...
puts "Seeding Food Groups (Parents)..."
parent_groups_map = {}
CSV.foreach(Rails.root.join('db', 'data_sources', 'food_groups.csv'), headers: true, header_converters: :symbol) do |row|
  fg = find_or_create_resource(FoodGroup, { name: row[:name]&.strip }, {
    default_unit_name: row[:default_unit_name].presence&.strip,
  })
  parent_groups_map[fg.name] = fg.id
end
puts "Food Groups (Parents) seeded: #{FoodGroup.where(parent_food_group_id: nil).count}"

puts "Seeding Food Subgroups..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'food_subgroups.csv'), headers: true, header_converters: :symbol) do |row|
  parent_name = row[:food_group_name]&.strip
  parent_id = parent_groups_map[parent_name]
  raise "ERROR: Parent FoodGroup '#{parent_name}' not found for subgroup '#{row[:name]&.strip}'" unless parent_id

  parent_food_group_for_subgroup = FoodGroup.find(parent_id)
  find_or_create_resource(FoodGroup, { name: row[:name]&.strip }, {
    parent_food_group_id: parent_id,
    default_unit_name: parent_food_group_for_subgroup.default_unit_name
  })
end
puts "Total Food Groups (incl. subgroups) seeded: #{FoodGroup.count}"

# 4. Dietary Patterns (dietary_patterns.csv)
# ... (unchanged) ...
puts "Seeding Dietary Patterns..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'dietary_patterns.csv'), headers: true, header_converters: :symbol) do |row|
  find_or_create_resource(DietaryPattern, { name: row[:name]&.strip }, {
    description: row[:description].presence,
    source_document_reference: row[:source_document_reference].presence
  })
end
puts "Dietary Patterns seeded: #{DietaryPattern.count}"


# --- Phase 3: Dependent DRI & EER Data from CSVs ---

# 5. EER Profiles (eer_profiles.csv)
# ... (unchanged) ...
puts "Seeding EER Profiles..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_profiles.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group = LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?
  find_or_create_resource(EerProfile, { name: row[:name]&.strip }, {
    source_table_reference: row[:source_table_reference].presence,
    life_stage_group_id: life_stage_group&.id,
    sex_filter: row[:sex_filter].presence&.strip,
    age_min_months_filter: row[:age_min_months_filter].present? ? row[:age_min_months_filter].to_i : nil,
    age_max_months_filter: row[:age_max_months_filter].present? ? row[:age_max_months_filter].to_i : nil,
    pal_category_applicable: row[:pal_category_applicable].presence&.strip,
    coefficient_intercept: row[:coefficient_intercept].present? ? row[:coefficient_intercept].to_f : nil,
    coefficient_age_years: row[:coefficient_age_years].present? ? row[:coefficient_age_years].to_f : nil,
    coefficient_age_months: row[:coefficient_age_months].present? ? row[:coefficient_age_months].to_f : nil,
    coefficient_height_cm: row[:coefficient_height_cm].present? ? row[:coefficient_height_cm].to_f : nil,
    coefficient_weight_kg: row[:coefficient_weight_kg].present? ? row[:coefficient_weight_kg].to_f : nil,
    coefficient_pal_value: row[:coefficient_pal_value].present? ? row[:coefficient_pal_value].to_f : nil,
    coefficient_gestation_weeks: row[:coefficient_gestation_weeks].present? ? row[:coefficient_gestation_weeks].to_f : nil,
    equation_basis: row[:equation_basis].presence,
    standard_error_of_predicted_value_kcal: row[:standard_error_of_predicted_value_kcal].present? ? row[:standard_error_of_predicted_value_kcal].to_f : nil,
    notes: row[:notes].presence
  })
end
puts "EER Profiles seeded: #{EerProfile.count}"

# 6. EER Additive Components (eer_additive_components.csv)
# ... (unchanged) ...
puts "Seeding EER Additive Components..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_additive_components.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group = LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?

  find_by_attrs = {
    component_type: row[:component_type]&.strip,
    life_stage_group_id: life_stage_group&.id,
    sex_filter: row[:sex_filter].presence&.strip,
    age_min_months_filter: row[:age_min_months_filter].present? ? row[:age_min_months_filter].to_i : nil,
    age_max_months_filter: row[:age_max_months_filter].present? ? row[:age_max_months_filter].to_i : nil,
    condition_pregnancy_trimester_filter: row[:condition_pregnancy_trimester_filter].present? ? row[:condition_pregnancy_trimester_filter].to_i : nil,
    condition_pre_pregnancy_bmi_category_filter: row[:condition_pre_pregnancy_bmi_category_filter].presence&.strip,
    condition_lactation_period_filter: row[:condition_lactation_period_filter].presence&.strip
  }
  find_by_attrs.compact!

  update_attrs = {
    source_table_reference: row[:source_document_reference].presence,
    value_kcal_day: row[:value_kcal_day].to_i,
    notes: row[:notes].presence
  }
  find_or_create_resource(EerAdditiveComponent, find_by_attrs, update_attrs)
end
puts "EER Additive Components seeded: #{EerAdditiveComponent.count}"

# 7. Growth Factors (growth_factors.csv)
# ... (unchanged) ...
puts "Seeding Growth Factors..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'growth_factors.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group_name_csv = row[:life_stage_group_id_placeholder]&.strip
  life_stage_group = LifeStageGroup.find_by(name: life_stage_group_name_csv)
  unless life_stage_group
    puts "WARN: LifeStageGroup '#{life_stage_group_name_csv}' not found for GrowthFactor. CSV Row: #{row.to_h}. Skipping."
    next
  end

  find_by_attrs = { life_stage_group_id: life_stage_group.id }
  update_attrs = {
    factor_value: row[:factor_value].to_f,
    source_document_reference: row[:source_document_reference].presence
  }
  find_or_create_resource(GrowthFactor, find_by_attrs, update_attrs)
end
puts "Growth Factors seeded: #{GrowthFactor.count}"

# 8. PAL Definitions (pal_definitions.csv)
# ... (Mostly unchanged, minor refinement to ensure `pluck` returns names if records exist)
puts "Seeding PAL Definitions..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'pal_definitions.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_name_from_csv = row[:life_stage_name]&.strip

  target_life_stage_group_names = case life_stage_name_from_csv
    when "General Adult Male"
      LifeStageGroup.where(sex: 'male').where("min_age_months >= ?", 228).pluck(:name).presence || []
    when "General Adult Female"
      LifeStageGroup.where(sex: 'female').where("min_age_months >= ?", 228).pluck(:name).presence || []
    when "General Boys 3-18 years"
      LifeStageGroup.where(sex: 'male', min_age_months: 36..227).pluck(:name).presence || []
    when "General Girls 3-18 years"
      LifeStageGroup.where(sex: 'female', min_age_months: 36..227).pluck(:name).presence || []
    when "Adults 19+ years"
      LifeStageGroup.where("min_age_months >= 228 AND special_condition IS NULL").pluck(:name).presence || []
    when "Children 0-2.99 years", "Children 0-2 years"
      LifeStageGroup.where("max_age_months < 36").pluck(:name).presence || []
    when "Children 3-8 years", "Children 3-8.99 years"
      LifeStageGroup.where(min_age_months: 36..107, sex: 'any', special_condition: nil).pluck(:name).presence || LifeStageGroup.where(name: "Children 4-8 years").pluck(:name).presence || []
    when "Children 9-13 years", "Children 9-13.99 years"
      LifeStageGroup.where(min_age_months: 108..167, sex: ['male', 'female'], special_condition: nil).pluck(:name).uniq.presence || []
    when "Adolescents 14-18 years", "Adolescents 14-18.99 years"
      LifeStageGroup.where(min_age_months: 168..227, sex: ['male', 'female'], special_condition: nil).pluck(:name).uniq.presence || []
    when "Adults 19-30 years"
        LifeStageGroup.where(sex: ['male', 'female']).where(min_age_months: 228..371, special_condition: nil).pluck(:name).uniq.presence || []
    when "Adults 31-50 years"
        LifeStageGroup.where(sex: ['male', 'female']).where(min_age_months: 372..611, special_condition: nil).pluck(:name).uniq.presence || []
    when "Adults 51-70 years"
        LifeStageGroup.where(sex: ['male', 'female']).where(min_age_months: 612..851, special_condition: nil).pluck(:name).uniq.presence || []
    when "Adults 71+ years"
        LifeStageGroup.where(sex: ['male', 'female']).where("min_age_months >= 852 AND special_condition IS NULL").pluck(:name).uniq.presence || []
    when "Adults 19-70.99 years", "Adults 19-70 years"
      LifeStageGroup.where("min_age_months >= 228 AND max_age_months < 852 AND special_condition IS NULL").pluck(:name).presence || []
    else
      existing_group = LifeStageGroup.find_by(name: life_stage_name_from_csv)
      existing_group ? [existing_group.name] : []
  end

  if target_life_stage_group_names.empty?
    puts "WARN: No LifeStageGroup found for PAL Definition mapping: '#{life_stage_name_from_csv}'. Skipping this PAL entry."
    next
  end
  # ... (rest of PAL definition seeding logic unchanged) ...
  target_life_stage_group_names.each do |resolved_lsg_name|
    life_stage_group = LifeStageGroup.find_by(name: resolved_lsg_name)
    unless life_stage_group
      puts "WARN: PAL seeding - Could not find LifeStageGroup for resolved name '#{resolved_lsg_name}' (from CSV PAL name '#{life_stage_name_from_csv}')"
      next
    end

    find_by_attrs = { life_stage_group_id: life_stage_group.id }

    pal_category_csv = row[:pal_category]&.strip
    percentile_value_csv = row[:percentile_value]&.strip

    if pal_category_csv.present? && row[:coefficient_for_eer_equation].present?
      find_by_attrs[:pal_category] = pal_category_csv
      find_by_attrs[:percentile_value] = nil
    elsif percentile_value_csv.present? && row[:pal_value_at_percentile].present?
      find_by_attrs[:pal_category] = pal_category_csv.presence || "Default_Percentile_Category" # Placeholder if CSV category is blank for percentile rows
      find_by_attrs[:percentile_value] = percentile_value_csv.to_i
    else
      puts "WARN: Skipping PAL definition row due to unclear type (missing key fields): #{row.to_h}"
      next
    end

    update_attrs = {}
    update_attrs[:pal_range_min_value] = row[:pal_range_min_value].to_f if row[:pal_range_min_value].present?
    update_attrs[:pal_range_max_value] = row[:pal_range_max_value].to_f if row[:pal_range_max_value].present?
    update_attrs[:pal_value_at_percentile] = row[:pal_value_at_percentile].to_f if row[:pal_value_at_percentile].present?
    update_attrs[:coefficient_for_eer_equation] = row[:coefficient_for_eer_equation].to_f if row[:coefficient_for_eer_equation].present?
    update_attrs[:source_document_reference] = row[:source_document_reference].presence if row[:source_document_reference].present?
    update_attrs[:pal_category] = find_by_attrs[:pal_category]
    update_attrs[:percentile_value] = find_by_attrs[:percentile_value] if find_by_attrs.key?(:percentile_value)

    find_or_create_resource(PalDefinition, find_by_attrs, update_attrs)
  end
end
puts "PAL Definitions seeded: #{PalDefinition.count}"


# 9. Reference Anthropometries (reference_anthropometries.csv)
# ... (unchanged from previous correct version) ...
puts "Seeding Reference Anthropometries..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'reference_anthropometries.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_name_csv = row[:life_stage_group_id_placeholder]&.strip
  life_stage_name_db = case life_stage_name_csv
    when "Adult Males Reference" then "Males 19-30 years"
    when "Adult Females Reference" then "Females 19-30 years"
    when "Infants 2-6 months" then "Infants 0-6 months"
    when "Infants 7-11 months" then "Infants 7-12 months"
    when "Children 1-3 years" then "Children 1-3 years"
    when "Children 4-8 years" then "Children 4-8 years"
    when "Males 9-13 years" then "Males 9-13 years"
    when "Males 14-18 years" then "Males 14-18 years"
    when "Females 9-13 years" then "Females 9-13 years"
    when "Females 14-18 years" then "Females 14-18 years"
    when "Infants 0-11 months DLW" then "Infants 7-12 months"
    when "Children 1-8 years DLW" then "Children 4-8 years"
    when "Children 9-18 years DLW" then "Males 14-18 years"
    when "Adults 19+ years DLW" then "Males 19-30 years"
    when "Pregnant/Lactating Women DLW" then "Pregnancy 19-30 years 1st Trimester"
    else life_stage_name_csv
  end

  life_stage_group = LifeStageGroup.find_by(name: life_stage_name_db)
  unless life_stage_group
    puts "WARN: Reference Anthropometry - LifeStageGroup '#{life_stage_name_db}' (mapped from CSV '#{life_stage_name_csv}') not found. Skipping."
    next
  end

  find_or_create_resource(ReferenceAnthropometry, { life_stage_group_id: life_stage_group.id }, {
    reference_height_cm: row[:reference_height_cm].present? ? row[:reference_height_cm].to_f : nil,
    reference_weight_kg: row[:reference_weight_kg].present? ? row[:reference_weight_kg].to_f : nil,
    median_bmi: row[:median_bmi].present? ? row[:median_bmi].to_f : nil,
    source_document_reference: row[:source_document_reference].presence
  })
end
puts "Reference Anthropometries seeded: #{ReferenceAnthropometry.count}"


# 10. DRI Values (dri_values.csv)
puts "Seeding DRI Values..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'dri_values.csv'), headers: true, header_converters: :symbol) do |row|
  nutrient_identifier_csv = row[:nutrient_identifier]&.strip
  db_nutrient_identifier = case nutrient_identifier_csv
    when "BIOTIN" then "BIOT"
    when "/CU" then "CU"
    when "VANADIUM" then "VANAD" # Ensure 'VANAD' is the dri_identifier for Vanadium in nutrients.csv
    else nutrient_identifier_csv
  end

  nutrient = Nutrient.find_by(dri_identifier: db_nutrient_identifier)
  life_stage_name_csv = row[:life_stage_name]&.strip

  resolved_life_stage_group_names = case life_stage_name_csv
    # ... (mappings from previous correct version, with additions for new errors) ...
    when "Children 9-13 years", "Adolescents 9-13 years"
      ["Males 9-13 years", "Females 9-13 years"]
    when "Boys 9-13 years" then ["Males 9-13 years"]
    when "Girls 9-13 years" then ["Females 9-13 years"]
    when "Children 14-18 years", "Adolescents 14-18 years"
      ["Males 14-18 years", "Females 14-18 years"]
    when "Adolescents 9-18 years"
      ["Males 9-13 years", "Females 9-13 years", "Males 14-18 years", "Females 14-18 years"]
    when "Children 19-30 years", "Adults 19-30 years"
      ["Males 19-30 years", "Females 19-30 years"]
    when "Children 31-50 years", "Adults 31-50 years"
      ["Males 31-50 years", "Females 31-50 years"]
    when "Adults 51+ years", "Adults 51-70 years", "Adults >=51 years"
      ["Males 51+ years", "Females 51+ years"]
    when "Adults 71+ years", "Adults >70 years", "Females >70 years", "Males >70 years", "Men >70 years", "Women >70 years"
      names = []
      names << "Males 71+ years" if life_stage_name_csv.match?(/Males|Men|Adults >70 years|Adults 71\+ years/)
      names << "Females 71+ years" if life_stage_name_csv.match?(/Females|Women|Adults >70 years|Adults 71\+ years/)
      names.uniq.empty? ? [life_stage_name_csv] : names.uniq
    when "Men 19-30 years" then ["Males 19-30 years"]
    when "Women 19-30 years" then ["Females 19-30 years"]
    when "Men 31-50 years" then ["Males 31-50 years"]
    when "Women 31-50 years" then ["Females 31-50 years"]
    when "Men 51+ years", "Men 51-70 years" then ["Males 51+ years"]
    when "Women 51+ years", "Women 51-70 years" then ["Females 51+ years"]
    when "Children 4-8 years"
      ["Children 4-8 years"]
    when "Infants 0-12 months"
      ["Infants 0-6 months", "Infants 7-12 months"]
    when "Pregnancy (all ages)", "Pregnancy 14-50 years"
      LifeStageGroup.where(special_condition: 'pregnancy').pluck(:name).presence || []
    when "Lactation (all ages)", "Lactation 14-50 years"
      LifeStageGroup.where(special_condition: 'lactation').pluck(:name).presence || []
    when "Pregnancy <=18 years", "Pregnancy 14-18 years"
      LifeStageGroup.where(special_condition: 'pregnancy').where("name LIKE '%14-18 years%'").pluck(:name).presence || []
    when "Pregnancy 19-30 years"
      LifeStageGroup.where(special_condition: 'pregnancy').where("name LIKE '%19-30 years%'").pluck(:name).presence || []
    when "Pregnancy 31-50 years"
      LifeStageGroup.where(special_condition: 'pregnancy').where("name LIKE '%31-50 years%'").pluck(:name).presence || []
    when "Pregnancy 19-50 years", "Pregnancy >=19 years"
      LifeStageGroup.where(special_condition: 'pregnancy').where("name LIKE '%19-30 years%' OR name LIKE '%31-50 years%'").pluck(:name).presence || []
    when "Lactation <=18 years", "Lactation 14-18 years"
      LifeStageGroup.where(special_condition: 'lactation').where("name LIKE '%14-18 years%'").pluck(:name).presence || []
    when "Lactation 19-30 years"
      LifeStageGroup.where(special_condition: 'lactation').where("name LIKE '%19-30 years%'").pluck(:name).presence || []
    when "Lactation 31-50 years"
      LifeStageGroup.where(special_condition: 'lactation').where("name LIKE '%31-50 years%'").pluck(:name).presence || []
    when "Lactation 19-50 years", "Lactation >=19 years"
      LifeStageGroup.where(special_condition: 'lactation').where("name LIKE '%19-30 years%' OR name LIKE '%31-50 years%'").pluck(:name).presence || []
    when "Adults >18 years", "Adults >=19 years"
      LifeStageGroup.where("min_age_months >= 228 AND special_condition IS NULL").pluck(:name).presence || []
    when "Adults 19-50 years"
      LifeStageGroup.where(name: ["Males 19-30 years", "Females 19-30 years", "Males 31-50 years", "Females 31-50 years"]).pluck(:name).presence || []
    when "Males >19 years", "Males >=19 years", "Males 19+ years"
      # This needs to cover all adult male groups if it's a general ">19"
      LifeStageGroup.where(sex: 'male').where("min_age_months >= 228 AND special_condition IS NULL").pluck(:name).presence || []
    when "Females >19 years", "Females >=19 years", "Females 19+ years"
      LifeStageGroup.where(sex: 'female').where("min_age_months >= 228 AND special_condition IS NULL").pluck(:name).presence || []
    when "Males 19-50 years"
        LifeStageGroup.where(name: ["Males 19-30 years", "Males 31-50 years"]).pluck(:name).presence || []
    when "Females 19-50 years"
        LifeStageGroup.where(name: ["Females 19-30 years", "Females 31-50 years"]).pluck(:name).presence || []
    when "Males >=51 years"
        LifeStageGroup.where(name: ["Males 51+ years", "Males 71+ years"]).pluck(:name).presence || []
    when "Females >=51 years"
        LifeStageGroup.where(name: ["Females 51+ years", "Females 71+ years"]).pluck(:name).presence || []
    when "Adults >=31 years"
        LifeStageGroup.where("min_age_months >= 372 AND special_condition IS NULL").pluck(:name).presence || []
    when "Males 19-70 years"
        LifeStageGroup.where(name: ["Males 19-30 years", "Males 31-50 years", "Males 51+ years"]).pluck(:name).presence || []
    when "Females 19-70 years"
        LifeStageGroup.where(name: ["Females 19-30 years", "Females 31-50 years", "Females 51+ years"]).pluck(:name).presence || []
    when "Adults 19-70 years"
        LifeStageGroup.where(name: ["Males 19-30 years", "Females 19-30 years",
                                    "Males 31-50 years", "Females 31-50 years",
                                    "Males 51+ years", "Females 51+ years"])
                      .pluck(:name).presence || []
    when "Children 4-13 years"
        LifeStageGroup.where(name: ["Children 4-8 years", "Males 9-13 years", "Females 9-13 years"]).pluck(:name).presence || []
    else [life_stage_name_csv]
  end

  unless nutrient
    puts "WARN: Nutrient with original DRI ID '#{nutrient_identifier_csv}' (mapped to '#{db_nutrient_identifier}') not found for DRI value from CSV row: #{row.to_h}. Skipping."
    next
  end

  if resolved_life_stage_group_names.empty? || resolved_life_stage_group_names.all?(&:blank?)
    direct_match_lsg = LifeStageGroup.find_by(name: life_stage_name_csv)
    if direct_match_lsg
      resolved_life_stage_group_names = [direct_match_lsg.name]
    else
      puts "WARN: No LifeStageGroup mapping found for DRI CSV name '#{life_stage_name_csv}'. Nutrient: #{nutrient.name}. Skipping."
      next
    end
  end
  # ... (rest of DRI value seeding logic unchanged) ...
  resolved_life_stage_group_names.each do |resolved_name|
    next if resolved_name.blank?
    life_stage_group = LifeStageGroup.find_by(name: resolved_name)
    unless life_stage_group
      puts "ERROR: LifeStageGroup '#{resolved_name}' (resolved from CSV '#{life_stage_name_csv}') not found for DRI value. Nutrient: #{nutrient.name}. CSV Row: #{row.to_h}"
      next
    end

    find_by_attrs = {
      nutrient_id: nutrient.id,
      life_stage_group_id: life_stage_group.id,
      dri_type: row[:dri_type]&.strip
    }
    update_attrs = {
      value_numeric: row[:value_numeric].present? ? row[:value_numeric].to_f : nil,
      value_string: row[:value_string].presence&.strip,
      unit: row[:unit]&.strip,
      source_of_goal: row[:source_of_goal].presence&.strip,
      criterion: row[:criterion].presence&.strip,
      footnote_marker: row[:footnote_marker].presence&.strip&.truncate(10),
      notes: row[:notes].presence,
      source_document_reference: row[:source_document].presence
    }
    find_or_create_resource(DriValue, find_by_attrs, update_attrs)
  end
end
puts "DRI Values seeded: #{DriValue.count}"


# 11. Dietary Pattern Components
puts "Seeding Dietary Pattern Components (Food Group Recommendations and Calorie Level Limits)..."
dietary_pattern_calorie_levels_cache = {}
dietary_pattern_food_group_recommendations_amount_value_null_false =
  DietaryPatternFoodGroupRecommendation.columns_hash['amount_value'].null == false

CSV.foreach(Rails.root.join('db', 'data_sources', 'dietary_pattern_components.csv'), headers: true, header_converters: :symbol) do |row|
  dietary_pattern_name = row[:dietary_pattern_name]&.strip
  calorie_level_val = row[:calorie_level]&.strip&.to_i

  raise "ERROR: Missing dietary_pattern_name or calorie_level in row: #{row.to_h}" unless dietary_pattern_name && calorie_level_val

  dietary_pattern = DietaryPattern.find_by(name: dietary_pattern_name)
  raise "ERROR: DietaryPattern '#{dietary_pattern_name}' not found" unless dietary_pattern

  dpcl_key = [dietary_pattern.id, calorie_level_val]
  dietary_pattern_calorie_level = dietary_pattern_calorie_levels_cache[dpcl_key]

  unless dietary_pattern_calorie_level
    dietary_pattern_calorie_level = DietaryPatternCalorieLevel.find_or_initialize_by(
      dietary_pattern_id: dietary_pattern.id,
      calorie_level: calorie_level_val
    )
    dietary_pattern_calorie_level.save! if dietary_pattern_calorie_level.new_record?
    dietary_pattern_calorie_levels_cache[dpcl_key] = dietary_pattern_calorie_level
  end

  component_name_val = row[:component_name]&.strip
  food_group_name_csv = row[:food_group_name]&.strip # Used for "Oils" special case
  food_subgroup_name_csv = row[:food_subgroup_name]&.strip

  if component_name_val == "Limit on Calories for Other Uses" && food_group_name_csv.blank? && food_subgroup_name_csv.blank?
    # This is the "Limit on Calories for Other Uses" row type
    parsed_val = parse_amount_value(row[:amount_value])
    if row[:amount_unit]&.strip == "kcal"
      dietary_pattern_calorie_level.limit_on_calories_other_uses_kcal_day = parsed_val.present? ? parsed_val.to_i : nil
    elsif row[:amount_unit]&.strip == "%"
      dietary_pattern_calorie_level.limit_on_calories_other_uses_percent_day = parsed_val
    end
    dietary_pattern_calorie_level.save!
  else
    # This is a food group or subgroup recommendation row
    target_food_group_name = food_subgroup_name_csv.presence || food_group_name_csv.presence || component_name_val.presence

    # If, after trying subgroup, group, and component name, it's still blank, then it's an issue.
    if target_food_group_name.blank?
      puts "WARN: Dietary Pattern Component - Skipping row due to missing food group identifier. Row: #{row.to_h}"
      next # Skip this row
    end

    food_group = FoodGroup.find_by(name: target_food_group_name)
    unless food_group
        puts "WARN: Dietary Pattern Component - FoodGroup '#{target_food_group_name}' not found for component in pattern '#{dietary_pattern_name}'. CSV Row: #{row.to_h}. Skipping."
        next # Skip if food group not found
    end

    parsed_numeric_amount = parse_amount_value(row[:amount_value])

    if parsed_numeric_amount.nil? && dietary_pattern_food_group_recommendations_amount_value_null_false
      # If amount is required and nil, this is an issue with parsing or data.
      # For now, let's skip it with a warning instead of raising an error,
      # as some DGA tables might legitimately have "ND" or blank for amounts.
      puts "WARN: Dietary Pattern Component - Parsed amount value is nil for food_group '#{target_food_group_name}' in pattern '#{dietary_pattern_name}'. CSV Row: #{row.to_h}. Skipping recommendation."
      next
    end

    recommendation_attrs_to_update = {
      amount_value: parsed_numeric_amount,
      amount_frequency: row[:frequency].presence&.strip,
    }
    recommendation_find_by = {
      dietary_pattern_calorie_level_id: dietary_pattern_calorie_level.id,
      food_group_id: food_group.id
    }

    find_or_create_resource(DietaryPatternFoodGroupRecommendation, recommendation_find_by, recommendation_attrs_to_update)
  end
end


puts "Dietary Pattern Calorie Levels processed: #{DietaryPatternCalorieLevel.count}"
puts "Dietary Pattern Food Group Recommendations seeded: #{DietaryPatternFoodGroupRecommendation.count}"


puts "--------------------------------"
puts "Seeding completed successfully!"
