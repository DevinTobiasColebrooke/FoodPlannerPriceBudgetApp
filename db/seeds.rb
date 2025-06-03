# seeds.rb
require 'csv'

# --- Helper to parse fractional and range values for amounts ---
# Handles "1/2", "1 3/4", "2-3", "2.5"
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
  elsif value_str.include?('-') && value_str.match?(/\d+-\d+/) # range like "2-3", ensure it's not part of a name
    # For ranges, DGA typically implies the lower bound or an average.
    # We'll take the lower bound.
    return value_str.split('-').first.to_f.round(4)
  else # simple number
    return value_str.to_f.round(4)
  end
rescue StandardError => e
  puts "WARN: Could not parse amount_value '#{value_str}': #{e.message}. Returning nil."
  nil
end

# --- Helper to find or create/update resources (idempotent) ---
def find_or_create_resource(model_class, find_by_attrs, update_attrs = {})
  resource = model_class.find_or_initialize_by(find_by_attrs)

  # Attributes to set/update = find_by_attrs (to ensure they are set if new) + update_attrs
  # update_attrs take precedence if there are overlaps.
  all_attrs_to_set = find_by_attrs.merge(update_attrs)

  # Filter attributes to only those that exist on the model
  # Although assign_attributes does this, it's good for clarity and to avoid warnings.
  valid_attributes = all_attrs_to_set.select { |k, _| model_class.column_names.include?(k.to_s) }

  resource.assign_attributes(valid_attributes)

  if resource.new_record? || resource.changed?
    begin
      resource.save!
    rescue ActiveRecord::RecordInvalid => e
      puts "ERROR: Validation failed for #{model_class.name} with find_by_attrs: #{find_by_attrs}, update_attrs: #{update_attrs}. Errors: #{e.record.errors.full_messages.join(', ')}"
      puts "Attempted to save with attributes: #{valid_attributes.inspect}" # Debug attributes
    rescue => e
      puts "ERROR: Could not save #{model_class.name} with find_by_attrs: #{find_by_attrs}, update_attrs: #{update_attrs}. Error: #{e.message}"
      puts "Attempted to save with attributes: #{valid_attributes.inspect}" # Debug attributes
    end
  end
  resource
end

# --- Destruction Order ---
puts "Destroying existing data..."
UserManagement::UserGoal.destroy_all
UserManagement::UserAllergy.destroy_all
UserManagement::UserDietaryRestriction.destroy_all
UserManagement::UserKitchenEquipment.destroy_all
Shopping::ShoppingListItem.destroy_all
MealPlanning::MealPlanEntry.destroy_all
MealPlanning::RecipeNutritionItem.destroy_all
MealPlanning::RecipeIngredient.destroy_all

Nutrition::DietaryPatternFoodGroupRecommendation.destroy_all
Nutrition::DietaryPatternCalorieLevel.destroy_all
Nutrition::DriValue.destroy_all # Depends on Nutrient and LifeStageGroup
Nutrition::GrowthFactor.destroy_all
Nutrition::PalDefinition.destroy_all
Nutrition::ReferenceAnthropometry.destroy_all
Nutrition::EerAdditiveComponent.destroy_all
Nutrition::EerProfile.destroy_all

Shopping::ShoppingList.destroy_all
MealPlanning::Recipe.destroy_all
MealPlanning::Ingredient.destroy_all
Shopping::Store.destroy_all
UserManagement::Session.destroy_all
UserManagement::User.destroy_all

UserManagement::Goal.destroy_all
UserManagement::Allergy.destroy_all
UserManagement::DietaryRestriction.destroy_all
UserManagement::KitchenEquipment.destroy_all

# Critical: Nutrient must be destroyed before tables that reference it,
# but after tables that it might reference (if any, none in this case).
# It's referenced by DriValue, RecipeNutritionItem.
Nutrition::Nutrient.destroy_all # Destroy Nutrients

Nutrition::FoodGroup.where.not(parent_food_group_id: nil).destroy_all
Nutrition::FoodGroup.where(parent_food_group_id: nil).destroy_all
Nutrition::DietaryPattern.destroy_all
Nutrition::LifeStageGroup.destroy_all

puts "All specified existing data destroyed."
puts "--------------------------------"

# --- Phase 1: Simple Lookup Table Seeding ---
puts "Seeding Goals..."
[
  { name: "Plan my meals for me", description: "Science based algorithmn plans meals for you, so you don't have to think about meals." },
  { name: "Meet Protein Goals", description: "A timer is set for maximum protein intake." },
  { name: "Weight Loss", description: "Focus on calorie deficit and nutrient-dense foods." },
  { name: "Eat Healthier", description: "Incorporate more whole foods and balanced meals." },
  { name: "Save Money", description: "Budget-friendly recipes and smart shopping." },
  { name: "Learn to Cook", description: "Beginner-friendly recipes and cooking tips." },
  { name: "Meal Prep Efficiency", description: "Recipes suitable for batch cooking and quick assembly." }
].each { |attrs| find_or_create_resource(UserManagement::Goal, { name: attrs[:name] }, attrs.except(:name)) }
puts "Goals seeded: #{UserManagement::Goal.count}"

puts "Seeding Allergies..."
[
  { name: "Dairy" }, { name: "Eggs" }, { name: "Tree Nuts" }, { name: "Peanuts" },
  { name: "Shellfish" }, { name: "Soy" }, { name: "Gluten" }, { name: "Fish" }, { name: "Sesame" }
].each { |attrs| find_or_create_resource(UserManagement::Allergy, { name: attrs[:name] }, attrs.except(:name)) }
puts "Allergies seeded: #{UserManagement::Allergy.count}"

puts "Seeding Kitchen Equipment..."
[
  { name: "Instapot / Pressure Cooker" }, { name: "Blender" }, { name: "Immersion Blender" },
  { name: "Food Processor" }, { name: "Strainer / Colander" }, { name: "Juicer" },
  { name: "Oven" }, { name: "Microwave" }, { name: "Air Fryer" }
].each { |attrs| find_or_create_resource(UserManagement::KitchenEquipment, { name: attrs[:name] }, attrs.except(:name)) }
puts "Kitchen Equipment seeded: #{UserManagement::KitchenEquipment.count}"

puts "Seeding Dietary Restrictions..."
[
  { name: "Vegan", description: "Excludes all animal products and by-products" },
  { name: "Vegetarian", description: "Excludes meat, fish, and poultry" },
  { name: "Low-Carb", description: "Restricts carbohydrate intake" }
].each { |attrs| find_or_create_resource(UserManagement::DietaryRestriction, { name: attrs[:name] }, attrs.except(:name)) }
puts "Dietary Restrictions seeded: #{UserManagement::DietaryRestriction.count}"

puts "Seeding Legal Documents..."
legal_docs = [
  {
    title: "Privacy Policy",
    content: File.read(Rails.root.join('app', 'views', 'legal_documents', 'privacy_policy.html.erb')),
    document_type: "privacy_policy",
    version: "1.0"
  },
  {
    title: "Terms of Service",
    content: File.read(Rails.root.join('app', 'views', 'legal_documents', 'terms_of_service.html.erb')),
    document_type: "terms_of_service",
    version: "1.0"
  }
]
legal_docs.each do |attrs|
  doc = LegalDocument.find_or_initialize_by(document_type: attrs[:document_type], version: attrs[:version])
  doc.title = attrs[:title]
  doc.content = attrs[:content]
  doc.save!
end
puts "Legal Documents seeded: #{LegalDocument.count}"

# --- Phase 2: Foundational Data from CSVs (Order is CRITICAL) ---
puts "Seeding Foundational Data from CSV files..."

# 1. Nutrients (nutrients.csv) - MUST be seeded before DRI Values, RecipeNutritionItems etc.
puts "Seeding Nutrients..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'nutrients.csv'), headers: true, header_converters: :symbol) do |row|
  find_or_create_resource(Nutrition::Nutrient, { dri_identifier: row[:dri_identifier]&.strip }, {
    name: row[:name]&.strip,
    category: row[:category]&.strip,
    default_unit: row[:default_unit]&.strip,
    analysis_unit: row[:analysis_unit]&.strip,
    conversion_factor: row[:conversion_factor].present? ? row[:conversion_factor].to_f : nil,
    description: row[:description].presence, # Use .presence to convert blank strings to nil
    sort_order: row[:sort_order].present? ? row[:sort_order].to_i : nil
  })
end
puts "Nutrients seeded: #{Nutrition::Nutrient.count}"
# Diagnostic output for Nutrients
puts "Sample Nutrient (Protein/PROCNT): #{Nutrition::Nutrient.find_by(dri_identifier: 'PROCNT')&.attributes.inspect}"
puts "Sample Nutrient (Calcium/CA): #{Nutrition::Nutrient.find_by(dri_identifier: 'CA')&.attributes.inspect}"
puts "Nutrient count with nil dri_identifier: #{Nutrition::Nutrient.where(dri_identifier: nil).count}"

# 2. Life Stages (life_stages.csv -> LifeStageGroup model)
puts "Seeding Life Stage Groups..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'life_stages.csv'), headers: true, header_converters: :symbol) do |row|
  # Ensure max_age_months is correctly handled for blank values to avoid type errors with .to_i
  max_age_val = row[:max_age_months]
  # Default for open-ended max_age_months (e.g., "71+ years") is set to a high number (12000 months ~ 1000 years)
  # to signify no upper limit for practical purposes.
  max_age_months_int = max_age_val.present? && max_age_val.match?(/\A\d+\z/) ? max_age_val.to_i : 12000

  find_or_create_resource(Nutrition::LifeStageGroup, { name: row[:name]&.strip }, {
    min_age_months: row[:min_age_months].to_i,
    max_age_months: max_age_months_int,
    sex: row[:sex]&.strip&.downcase,
    special_condition: row[:special_condition].presence&.strip, # Uses presence to convert blank strings to nil
    trimester: row[:trimester].present? ? row[:trimester].to_i : nil,
    lactation_period: (row[:lactation_period].present? && row[:lactation_period].strip.length <= 20 ? row[:lactation_period].strip : nil), # Ensures within length limit
    notes: row[:notes].presence
  })
end
puts "Life Stage Groups seeded: #{Nutrition::LifeStageGroup.count}"

puts "--- Post LifeStageGroup Seeding Diagnostics ---"
puts "Distinct values for 'sex' in LifeStageGroup: #{Nutrition::LifeStageGroup.distinct.pluck(:sex).inspect}"
puts "Distinct values for 'special_condition' in LifeStageGroup: #{Nutrition::LifeStageGroup.distinct.pluck(:special_condition).inspect}"
puts "Count of LSGs with sex='male': #{Nutrition::LifeStageGroup.where(sex: 'male').count}"
puts "Count of LSGs with sex='female': #{Nutrition::LifeStageGroup.where(sex: 'female').count}"
puts "Count of LSGs with sex='any': #{Nutrition::LifeStageGroup.where(sex: 'any').count}"
puts "Count of LSGs with special_condition IS NULL: #{Nutrition::LifeStageGroup.where(special_condition: nil).count}"
puts "Count of LSGs with special_condition = '': #{Nutrition::LifeStageGroup.where(special_condition: '').count}"

puts "Sample 'Males 19-30 years' LSG: #{Nutrition::LifeStageGroup.find_by(name: 'Males 19-30 years')&.attributes.inspect}"
puts "Sample 'Children 4-8 years' LSG: #{Nutrition::LifeStageGroup.find_by(name: 'Children 4-8 years')&.attributes.inspect}"
puts "Sample 'Children 3 years' LSG: #{Nutrition::LifeStageGroup.find_by(name: 'Children 3 years')&.attributes.inspect}"
puts "--- End Post LifeStageGroup Seeding Diagnostics ---"

# 3. Food Groups (food_groups.csv & food_subgroups.csv for FoodGroup model)
puts "Seeding Food Groups (Parents)..."
parent_groups_map = {}
CSV.foreach(Rails.root.join('db', 'data_sources', 'food_groups.csv'), headers: true, header_converters: :symbol) do |row|
  fg = find_or_create_resource(Nutrition::FoodGroup, { name: row[:name]&.strip }, {
    default_unit_name: row[:default_unit_name].presence&.strip,
  })
  parent_groups_map[fg.name] = fg.id
end
puts "Food Groups (Parents) seeded: #{Nutrition::FoodGroup.where(parent_food_group_id: nil).count}"

puts "Seeding Food Subgroups..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'food_subgroups.csv'), headers: true, header_converters: :symbol) do |row|
  parent_name = row[:food_group_name]&.strip
  parent_id = parent_groups_map[parent_name]
  unless parent_id
    puts "ERROR: Parent FoodGroup '#{parent_name}' not found for subgroup '#{row[:name]&.strip}'. Skipping."
    next
  end

  parent_food_group_for_subgroup = Nutrition::FoodGroup.find(parent_id)
  find_or_create_resource(Nutrition::FoodGroup, { name: row[:name]&.strip }, {
    parent_food_group_id: parent_id,
    default_unit_name: parent_food_group_for_subgroup.default_unit_name # Inherit default unit
  })
end
puts "Total Food Groups (incl. subgroups) seeded: #{Nutrition::FoodGroup.count}"

# 4. Dietary Patterns (dietary_patterns.csv)
puts "Seeding Dietary Patterns..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'dietary_patterns.csv'), headers: true, header_converters: :symbol) do |row|
  find_or_create_resource(Nutrition::DietaryPattern, { name: row[:name]&.strip }, {
    description: row[:description].presence,
    source_document_reference: row[:source_document_reference].presence
  })
end
puts "Dietary Patterns seeded: #{Nutrition::DietaryPattern.count}"


# --- Phase 3: Dependent DRI & EER Data from CSVs ---

# 5. EER Profiles (eer_profiles.csv)
puts "Seeding EER Profiles..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_profiles.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group = Nutrition::LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?
  # EER Profiles are uniquely identified by name for simplicity in CSV, but ensure consistency.
  # If LifeStageGroup is meant to be part of uniqueness, add it to find_by_hash.
  find_or_create_resource(Nutrition::EerProfile, { name: row[:name]&.strip }, {
    source_table_reference: row[:source_table_reference].presence,
    life_stage_group_id: life_stage_group&.id, # Can be nil if the profile is generic
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
puts "EER Profiles seeded: #{Nutrition::EerProfile.count}"

# 6. EER Additive Components (eer_additive_components.csv)
puts "Seeding EER Additive Components..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_additive_components.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group = Nutrition::LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?

  find_by_attrs = {
    component_type: row[:component_type]&.strip,
    life_stage_group_id: life_stage_group&.id, # Can be nil for generic components
    sex_filter: row[:sex_filter].presence&.strip,
    age_min_months_filter: row[:age_min_months_filter].present? ? row[:age_min_months_filter].to_i : nil,
    age_max_months_filter: row[:age_max_months_filter].present? ? row[:age_max_months_filter].to_i : nil,
    condition_pregnancy_trimester_filter: row[:condition_pregnancy_trimester_filter].present? ? row[:condition_pregnancy_trimester_filter].to_i : nil,
    condition_pre_pregnancy_bmi_category_filter: row[:condition_pre_pregnancy_bmi_category_filter].presence&.strip,
    condition_lactation_period_filter: row[:condition_lactation_period_filter].presence&.strip&.truncate(20)
  }
  find_by_attrs.compact! # Remove nil values from find_by_attrs

  update_attrs = {
    value_kcal_day: row[:value_kcal_day].to_i,
    notes: row[:notes].presence,
    source_document_reference: row[:source_document_reference].presence
  }
  find_or_create_resource(Nutrition::EerAdditiveComponent, find_by_attrs, update_attrs)
end
puts "EER Additive Components seeded: #{Nutrition::EerAdditiveComponent.count}"

# 7. Growth Factors (growth_factors.csv)
puts "Seeding Growth Factors..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'growth_factors.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group_name_csv = row[:life_stage_group_id_placeholder]&.strip
  life_stage_group = Nutrition::LifeStageGroup.find_by(name: life_stage_group_name_csv)
  unless life_stage_group
    puts "WARN: LifeStageGroup '#{life_stage_group_name_csv}' not found for GrowthFactor. CSV Row: #{row.to_h}. Skipping."
    next
  end

  find_by_attrs = { life_stage_group_id: life_stage_group.id } # Assuming one growth factor per LSG
  update_attrs = {
    factor_value: row[:factor_value].to_f,
    source_document_reference: row[:source_document_reference].presence
  }
  find_or_create_resource(Nutrition::GrowthFactor, find_by_attrs, update_attrs)
end
puts "Growth Factors seeded: #{Nutrition::GrowthFactor.count}"

# 8. PAL Definitions (pal_definitions.csv)
puts "Seeding PAL Definitions..."

# Diagnostic: Check count for a known problematic query condition with more lenient special_condition check
# And ensure sex is queried in lowercase to match stored value
debug_gam_lsg_count = Nutrition::LifeStageGroup.where(sex: 'male') # Assuming 'male' is already lowercase from seeding
                                    .where(special_condition: [nil, ''])
                                    .where("min_age_months >= ?", 228)
                                    .count
puts "DEBUG (PAL section): Count of LSGs for 'General Adult Male' (male, >=228mo, spec_cond nil/''): #{debug_gam_lsg_count}"

debug_child_3_8_lsg_count = Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                                          .where("min_age_months >= 36 AND max_age_months <= 107") # 3 to <9 years
                                          .count
puts "DEBUG (PAL section): Count of LSGs for 'Children 3-8 years' (36-107mo, spec_cond nil/''): #{debug_child_3_8_lsg_count}"


CSV.foreach(Rails.root.join('db', 'data_sources', 'pal_definitions.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_name_from_csv = row[:life_stage_name]&.strip

  # Queries for LifeStageGroup should consistently use lowercase for sex
  # and [nil, ''] for special_condition where applicable.
  target_life_stage_group_names = case life_stage_name_from_csv
  when "General Adult Male"
    Nutrition::LifeStageGroup.where(sex: 'male')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= ?", 228)
                  .pluck(:name)
  when "General Adult Female"
    Nutrition::LifeStageGroup.where(sex: 'female')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= ?", 228)
                  .pluck(:name)
  when "General Boys 3-18 years"
    Nutrition::LifeStageGroup.where(sex: 'male')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= 36 AND max_age_months <= 227")
                  .pluck(:name)
  when "General Girls 3-18 years"
    Nutrition::LifeStageGroup.where(sex: 'female')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= 36 AND max_age_months <= 227")
                  .pluck(:name)
  # ... (ensure all other case branches also use sex: 'male'/'female' in lowercase and special_condition: [nil, ''])
  when "Children 3-8 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= 36 AND max_age_months <= 107")
                  .pluck(:name)
  when "Children 9-13 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= 108 AND max_age_months <= 167")
                  .pluck(:name)
  when "Adolescents 14-18 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= 168 AND max_age_months <= 227")
                  .pluck(:name)
  when "Adults 19+ years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= ?", 228)
                  .pluck(:name)
  when "Infants 0-6 months" # These typically don't have sex-specific general PALs, but rely on name
      Nutrition::LifeStageGroup.where(name: "Infants 0-6 months").pluck(:name)
  when "Infants 7-12 months"
      Nutrition::LifeStageGroup.where(name: "Infants 7-12 months").pluck(:name)
  when "Children 1-3 years"
      Nutrition::LifeStageGroup.where(name: "Children 1-3 years").pluck(:name)
  when "Children 4-8 years" # This maps to the specific LifeStageGroup from CSV named "Children 4-8 years"
                            # and other relevant groups.
      Nutrition::LifeStageGroup.where(name: "Children 4-8 years") # Direct name match
                  .or(Nutrition::LifeStageGroup.where(special_condition: [nil, '']) # Broader match for other 'any' sex groups
                                    .where(sex: ['any', 'male', 'female']) # Be explicit if needed
                                    .where("min_age_months >= 48 AND max_age_months <= 107"))
                  .pluck(:name).uniq
  when "Adults 19-30 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female']) # Assuming these can apply to 'any' sex groups if not gender specific
                  .where("min_age_months >= 228 AND max_age_months <= 371")
                  .pluck(:name)
  when "Adults 31-50 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 372 AND max_age_months <= 611")
                  .pluck(:name)
  when "Adults 51-70 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 612 AND max_age_months <= 851")
                  .pluck(:name)
  when "Children 0-2.99 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 0 AND max_age_months <= 35")
                  .pluck(:name)
  when "Children 3-8.99 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female']) # PALs for "Children" often apply to both sexes if not specified
                  .where("min_age_months >= 36 AND max_age_months <= 107")
                  .pluck(:name)
  when "Children 9-13.99 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 108 AND max_age_months <= 167")
                  .pluck(:name)
  when "Adolescents 14-18.99 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 168 AND max_age_months <= 227")
                  .pluck(:name)
  when "Adults 19-70.99 years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 228 AND max_age_months <= 851")
                  .pluck(:name)
  when "Adults 71+ years"
    Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 852")
                  .pluck(:name)
  else
    # Fallback for direct match by name if not covered above
    existing_group = Nutrition::LifeStageGroup.find_by(name: life_stage_name_from_csv)
    target_life_stage_group_names = existing_group ? [existing_group.name] : []
  end

  if target_life_stage_group_names.empty?
    puts "WARN: No LifeStageGroup found for PAL Definition mapping: '#{life_stage_name_from_csv}'. Skipping PAL entry: #{row.to_h}"
    next
  end

  target_life_stage_group_names.uniq.each do |resolved_lsg_name|
    life_stage_group = Nutrition::LifeStageGroup.find_by(name: resolved_lsg_name)
    unless life_stage_group
      puts "ERROR: PAL seeding - Could not re-find LifeStageGroup for resolved name '#{resolved_lsg_name}' (Original CSV name: '#{life_stage_name_from_csv}'). Skipping."
      next
    end

    pal_category_csv = row[:pal_category]&.strip
    coefficient_csv = row[:coefficient_for_eer_equation]&.strip
    percentile_val_csv = row[:percentile_value]&.strip
    pal_value_at_percentile_source_csv = row[:pal_value_at_percentile]&.strip
    pal_range_min_csv = row[:pal_range_min_value]&.strip
    pal_range_max_csv = row[:pal_range_max_value]&.strip

    find_by_attrs = { life_stage_group_id: life_stage_group.id }
    update_attrs = { source_document_reference: row[:source_document_reference].presence }

    # Determine the type of PAL entry and set attributes accordingly
    if pal_category_csv.present? && coefficient_csv.present? # EER Coefficient type
      find_by_attrs[:pal_category] = pal_category_csv
      update_attrs[:coefficient_for_eer_equation] = Float(coefficient_csv) rescue nil
    elsif percentile_val_csv.present? && pal_value_at_percentile_source_csv.present? # Percentile with direct value type
      find_by_attrs[:pal_category] = pal_category_csv.presence || "Percentile_#{percentile_val_csv}"
      find_by_attrs[:percentile_value] = Integer(percentile_val_csv) rescue nil
      update_attrs[:pal_value_at_percentile] = Float(pal_value_at_percentile_source_csv) rescue nil
    elsif percentile_val_csv.present? && pal_range_min_csv.present? && pal_value_at_percentile_source_csv.blank? # Percentile using min_range as value
      find_by_attrs[:pal_category] = pal_category_csv.presence || "Percentile_#{percentile_val_csv}"
      find_by_attrs[:percentile_value] = Integer(percentile_val_csv) rescue nil
      update_attrs[:pal_value_at_percentile] = Float(pal_range_min_csv) rescue nil
    elsif pal_category_csv.present? && pal_range_min_csv.present? # PAL Range type
      find_by_attrs[:pal_category] = pal_category_csv
      update_attrs[:pal_range_min_value] = Float(pal_range_min_csv) rescue nil
      update_attrs[:pal_range_max_value] = Float(pal_range_max_csv) rescue nil if pal_range_max_csv.present?
    else
      next
    end

    update_attrs[:pal_category] = find_by_attrs[:pal_category] if find_by_attrs.key?(:pal_category)
    update_attrs[:percentile_value] = find_by_attrs[:percentile_value] if find_by_attrs.key?(:percentile_value)

    find_or_create_resource(Nutrition::PalDefinition, find_by_attrs, update_attrs)
  end
end
puts "PAL Definitions seeded: #{Nutrition::PalDefinition.count}"

# 9. Reference Anthropometries (reference_anthropometries.csv)
puts "Seeding Reference Anthropometries..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'reference_anthropometries.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_name_csv = row[:life_stage_group_id_placeholder]&.strip
  resolved_lsg_names = []

  # Handle empty placeholder upfront
  unless life_stage_name_csv.present?
    puts "WARN: Reference Anthropometry - CSV row has blank life_stage_group_id_placeholder. Skipping. CSV Row: #{row.to_h}"
    next
  end

  case life_stage_name_csv
  when "Adult Males Reference"
    # Assumption: Maps to a representative young adult male group for general reference.
    resolved_lsg_names = ["Males 19-30 years"]
  when "Adult Females Reference"
    # Assumption: Maps to a representative young adult female group for general reference.
    resolved_lsg_names = ["Females 19-30 years"]
  when "Infants 2-6 months"
    # Maps to the existing broader group "Infants 0-6 months"
    resolved_lsg_names = ["Infants 0-6 months"]
  when "Infants 7-11 months"
    # Maps to the existing broader group "Infants 7-12 months"
    resolved_lsg_names = ["Infants 7-12 months"]
  when "Children 1-3 years"
    resolved_lsg_names = ["Children 1-3 years"]
  when "Children 4-8 years"
    # This reference data applies to the general "Children 4-8 years" group
    # as well as its sex-specific counterparts.
    resolved_lsg_names = ["Children 4-8 years", "Males 4-8 years", "Females 4-8 years"]
  when "Males 9-13 years"
    resolved_lsg_names = ["Males 9-13 years"]
  when "Males 14-18 years"
    resolved_lsg_names = ["Males 14-18 years"]
  when "Males 19-30 years" # Distinct from "Adult Males Reference" if specific data exists
    resolved_lsg_names = ["Males 19-30 years"]
  when "Females 9-13 years"
    resolved_lsg_names = ["Females 9-13 years"]
  when "Females 14-18 years"
    resolved_lsg_names = ["Females 14-18 years"]
  when "Females 19-30 years" # Distinct from "Adult Females Reference"
    resolved_lsg_names = ["Females 19-30 years"]
  when "Infants 0-11 months DLW" # Doubly Labeled Water studies reference
    # Covers LifeStageGroups "Infants 0-6 months" and "Infants 7-12 months"
    resolved_lsg_names = ["Infants 0-6 months", "Infants 7-12 months"]
  when "Children 1-8 years DLW"
    # Covers groups overlapping with 12 to 107 months, no special conditions.
    age_min_filter = 12  # 1 year
    age_max_filter = 107 # 8 years and 11 months (up to, but not including, 9 years)
    resolved_lsg_names = Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                                       .where("min_age_months <= ? AND COALESCE(max_age_months, 12000) >= ?", age_max_filter, age_min_filter)
                                       .pluck(:name)
  when "Children 9-18 years DLW"
    # Covers groups overlapping with 108 to 227 months, no special conditions.
    age_min_filter = 108 # 9 years
    age_max_filter = 227 # 18 years and 11 months (up to, but not including, 19 years)
    resolved_lsg_names = Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                                       .where("min_age_months <= ? AND COALESCE(max_age_months, 12000) >= ?", age_max_filter, age_min_filter)
                                       .pluck(:name)
  when "Adults 19+ years DLW"
    # Covers groups from 228 months upwards, no special conditions.
    resolved_lsg_names = Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                                       .where("min_age_months >= ?", 228)
                                       .pluck(:name)
  when "Pregnant/Lactating Women DLW"
    # Covers all pregnant or lactating female groups.
    resolved_lsg_names = Nutrition::LifeStageGroup.where(sex: 'female')
                                       .where(special_condition: ['pregnancy', 'lactation'])
                                       .pluck(:name)
  else
    # Fallback: Attempt a direct match by name if the placeholder wasn't handled above.
    # This can be useful if new, directly named placeholders are added to the CSV.
    group = Nutrition::LifeStageGroup.find_by(name: life_stage_name_csv)
    resolved_lsg_names = [group.name] if group
  end

  # Ensure it's a unique array of names
  resolved_lsg_names = Array(resolved_lsg_names).flatten.compact.uniq

  if resolved_lsg_names.empty?
    puts "WARN: Reference Anthropometry - LifeStageGroup placeholder '#{life_stage_name_csv}' did not map to any known LifeStageGroups. Skipping. CSV Row: #{row.to_h}"
    next
  end

  resolved_lsg_names.each do |lsg_name|
    life_stage_group = Nutrition::LifeStageGroup.find_by(name: lsg_name)
    unless life_stage_group
      # This error should ideally not occur if the mapping logic above and LifeStageGroup seeding are correct.
      puts "ERROR: Reference Anthropometry - Resolved LifeStageGroup name '#{lsg_name}' (from CSV placeholder '#{life_stage_name_csv}') not found in database. Skipping this specific entry."
      next
    end

    find_or_create_resource(Nutrition::ReferenceAnthropometry, { life_stage_group_id: life_stage_group.id }, {
      reference_height_cm: row[:reference_height_cm].present? ? row[:reference_height_cm].to_f : nil,
      reference_weight_kg: row[:reference_weight_kg].present? ? row[:reference_weight_kg].to_f : nil,
      median_bmi: row[:median_bmi].present? ? row[:median_bmi].to_f : nil,
      source_document_reference: row[:source_document_reference].presence
    })
  end
end
puts "Reference Anthropometries seeded: #{Nutrition::ReferenceAnthropometry.count}"


# 10. DRI Values (dri_values.csv)
puts "Seeding DRI Values..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'dri_values.csv'), headers: true, header_converters: :symbol) do |row|
  nutrient_identifier_csv = row[:nutrient_identifier]&.strip
  db_nutrient_identifier = case nutrient_identifier_csv
                           when "BIOTIN" then "BIOT"
                           when "/CU" then "CU" # Assuming /CU from CSV should map to CU in DB
                           when "VANADIUM" then "VANAD"
                           else nutrient_identifier_csv
                           end

  nutrient = Nutrition::Nutrient.find_by(dri_identifier: db_nutrient_identifier)
  life_stage_name_csv = row[:life_stage_name]&.strip # The name from dri_values.csv

  unless nutrient
    puts "WARN: Nutrient with original DRI ID '#{nutrient_identifier_csv}' (mapped to DB ID '#{db_nutrient_identifier}') not found. Skipping DRI value. Row: #{row.to_h}"
    next
  end

  resolved_life_stage_group_names = [] # This will hold the DB LifeStageGroup names
  if life_stage_name_csv.blank?
    puts "WARN: DRI Value - CSV row has blank life_stage_name. Nutrient: #{nutrient.name}. Skipping. Row: #{row.to_h}"
    next
  end

  # --- BEGIN LifeStageGroup Mapping ---
  case life_stage_name_csv
  # Category 1: Exact or near-exact matches to LifeStageGroup names from life_stages.csv
  # These are assumed to map to a single LifeStageGroup entry.
  when "Infants 0-6 months", "Infants 7-12 months", "Toddlers 12-23 months", "Children 1-3 years", "Children 2-3 years",
       "Females 4-8 years", "Males 4-8 years", "Females 9-13 years", "Males 9-13 years",
       "Females 14-18 years", "Males 14-18 years", "Females 19-30 years", "Males 19-30 years",
       "Females 31-50 years", "Males 31-50 years", "Females 51+ years", "Males 51+ years", # Note: life_stages.csv has 51-70 and 71+
       "Females 71+ years", "Males 71+ years",
       "Pregnancy 14-18 years 1st Trimester", "Pregnancy 14-18 years 2nd Trimester", "Pregnancy 14-18 years 3rd Trimester",
       "Pregnancy 19-30 years 1st Trimester", "Pregnancy 19-30 years 2nd Trimester", "Pregnancy 19-30 years 3rd Trimester",
       "Pregnancy 31-50 years 1st Trimester", "Pregnancy 31-50 years 2nd Trimester", "Pregnancy 31-50 years 3rd Trimester",
       "Lactation 14-18 years 0-6 months", "Lactation 14-18 years 7-12 months",
       "Lactation 19-30 years 0-6 months", "Lactation 19-30 years 7-12 months",
       "Lactation 31-50 years 0-6 months", "Lactation 31-50 years 7-12 months"
    # For these, the CSV name is expected to be a direct LifeStageGroup name
    group = Nutrition::LifeStageGroup.find_by(name: life_stage_name_csv)
    resolved_life_stage_group_names = [group.name] if group

  # Category 2: Common DRI groupings that imply Male + Female counterparts
  when "Children 4-8 years" # General term implies all relevant groups
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Children 4-8 years", "Males 4-8 years", "Females 4-8 years"]).pluck(:name)
  when "Children 9-13 years", "Boys 9-13 years", "Girls 9-13 years" # Includes sex-specific synonyms
    # If "Children 9-13 years" appears, map to both. If "Boys..." or "Girls...", map to specific.
    if life_stage_name_csv == "Children 9-13 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Males 9-13 years", "Females 9-13 years"]).pluck(:name)
    elsif life_stage_name_csv == "Boys 9-13 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Males 9-13 years").pluck(:name)
    elsif life_stage_name_csv == "Girls 9-13 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Females 9-13 years").pluck(:name)
    end
  when "Adolescents 14-18 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Males 14-18 years", "Females 14-18 years"]).pluck(:name)
  when "Adults 19-30 years", "Men 19-30 years", "Women 19-30 years"
    if life_stage_name_csv == "Adults 19-30 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Males 19-30 years", "Females 19-30 years"]).pluck(:name)
    elsif life_stage_name_csv == "Men 19-30 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Males 19-30 years").pluck(:name)
    elsif life_stage_name_csv == "Women 19-30 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Females 19-30 years").pluck(:name)
    end
  when "Adults 31-50 years", "Men 31-50 years", "Women 31-50 years"
    if life_stage_name_csv == "Adults 31-50 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Males 31-50 years", "Females 31-50 years"]).pluck(:name)
    elsif life_stage_name_csv == "Men 31-50 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Males 31-50 years").pluck(:name)
    elsif life_stage_name_csv == "Women 31-50 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Females 31-50 years").pluck(:name)
    end
  when "Adults 51-70 years", "Males 51-70 years", "Females 51-70 years", "Men 51-70 years", "Women 51-70 years"
    # life_stages.csv has "Males 51-70 years" and "Females 51-70 years"
    if life_stage_name_csv == "Adults 51-70 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Males 51-70 years", "Females 51-70 years"]).pluck(:name)
    elsif life_stage_name_csv == "Males 51-70 years" || life_stage_name_csv == "Men 51-70 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Males 51-70 years").pluck(:name)
    elsif life_stage_name_csv == "Females 51-70 years" || life_stage_name_csv == "Women 51-70 years"
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Females 51-70 years").pluck(:name)
    end
  when "Adults >70 years", "Men >70 years", "Women >70 years" # Corresponds to "71+ years" in life_stages.csv
    if life_stage_name_csv == "Adults >70 years"
        resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Males 71+ years", "Females 71+ years"]).pluck(:name)
    elsif life_stage_name_csv == "Men >70 years" # Covered by direct match "Males 71+ years" if CSV used that
        resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Males 71+ years").pluck(:name)
    elsif life_stage_name_csv == "Women >70 years"
        resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Females 71+ years").pluck(:name)
    end
  # Need to handle "Males >70 years" and "Females >70 years" if they are distinct from "Men >70 years" in CSV
  when "Males >70 years" # From your error log
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Males 71+ years").pluck(:name)
  when "Females >70 years" # From your error log
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: "Females 71+ years").pluck(:name)


  # Category 3: Broader Age/Sex Categories or Special Conditions
  when "Pregnancy <=18 years", "Pregnancy 14-18 years" # CSV term maps to specific trimesters
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Pregnancy 14-18 years 1st Trimester", "Pregnancy 14-18 years 2nd Trimester", "Pregnancy 14-18 years 3rd Trimester"
    ]).pluck(:name)
  when "Pregnancy 19-30 years" # CSV specific term, maps to its trimesters
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Pregnancy 19-30 years 1st Trimester", "Pregnancy 19-30 years 2nd Trimester", "Pregnancy 19-30 years 3rd Trimester"
    ]).pluck(:name)
  when "Pregnancy 31-50 years" # CSV specific term
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Pregnancy 31-50 years 1st Trimester", "Pregnancy 31-50 years 2nd Trimester", "Pregnancy 31-50 years 3rd Trimester"
    ]).pluck(:name)
  when "Pregnancy 19-50 years", "Pregnancy >=19 years" # CSV Broader term
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(special_condition: 'pregnancy').where(name: [
        "Pregnancy 19-30 years 1st Trimester", "Pregnancy 19-30 years 2nd Trimester", "Pregnancy 19-30 years 3rd Trimester",
        "Pregnancy 31-50 years 1st Trimester", "Pregnancy 31-50 years 2nd Trimester", "Pregnancy 31-50 years 3rd Trimester"
    ]).pluck(:name)
  when "Pregnancy 14-50 years", "Pregnancy (all ages)"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(special_condition: 'pregnancy').pluck(:name)

  when "Lactation <=18 years", "Lactation 14-18 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Lactation 14-18 years 0-6 months", "Lactation 14-18 years 7-12 months"
    ]).pluck(:name)
  when "Lactation 19-30 years" # CSV specific term
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Lactation 19-30 years 0-6 months", "Lactation 19-30 years 7-12 months"
    ]).pluck(:name)
  when "Lactation 31-50 years" # CSV specific term
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Lactation 31-50 years 0-6 months", "Lactation 31-50 years 7-12 months"
    ]).pluck(:name)
  when "Lactation 19-50 years", "Lactation >=19 years" # CSV Broader term
      resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(special_condition: 'lactation').where(name: [
          "Lactation 19-30 years 0-6 months", "Lactation 19-30 years 7-12 months",
          "Lactation 31-50 years 0-6 months", "Lactation 31-50 years 7-12 months"
      ]).pluck(:name)
  when "Lactation 14-50 years", "Lactation (all ages)"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(special_condition: 'lactation').pluck(:name)

  # Ranges spanning multiple standard groups
  when "Males 19-70 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                        .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 851).pluck(:name) # 19y to end of 70y
  when "Females 19-70 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                        .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 851).pluck(:name)
  when "Adolescents 9-18 years" # Broader than specific 9-13 and 14-18
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Males 9-13 years", "Females 9-13 years", "Males 14-18 years", "Females 14-18 years"
    ]).pluck(:name)
  when "Adults 19-70 years" # General term for both sexes
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                        .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 851).pluck(:name)
  when "Adults >=19 years", "Adults >18 years" # Synonyms
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                        .where("min_age_months >= ?", 228).pluck(:name) # min_age_months for 19 years
  when "Males >18 years", "Males >=19 years", "Males >19 years" # Synonyms
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                        .where("min_age_months >= ?", 228).pluck(:name)
  when "Females >18 years", "Females >=19 years", "Females >19 years" # Synonyms
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                        .where("min_age_months >= ?", 228).pluck(:name)
  when "Adults 19-50 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                        .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 611).pluck(:name) # Up to end of 50y
  when "Males 19-50 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                         .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 611).pluck(:name)
  when "Females 19-50 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                         .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 611).pluck(:name)
  when "Males >=51 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                        .where("min_age_months >= ?", 612).pluck(:name) # min_age_months for 51 years
  when "Females >=51 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                        .where("min_age_months >= ?", 612).pluck(:name)
  when "Adults >=51 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                        .where("min_age_months >= ?", 612).pluck(:name)
  when "Adults >=31 years"
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                        .where("min_age_months >= ?", 372).pluck(:name) # min_age_months for 31 years
  when "Children 4-13 years" # Covers 4-8 and 9-13
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: [
      "Children 4-8 years", "Males 4-8 years", "Females 4-8 years",
      "Males 9-13 years", "Females 9-13 years"
    ]).pluck(:name)
  when "Infants 0-12 months" # Covers 0-6 and 7-12
    resolved_life_stage_group_names = Nutrition::LifeStageGroup.where(name: ["Infants 0-6 months", "Infants 7-12 months"]).pluck(:name)


  # Category 4: Fallback for any unhandled exact matches
  else
    # This is a safety net. Ideally, all CSV values should be explicitly handled above.
    group = Nutrition::LifeStageGroup.find_by(name: life_stage_name_csv)
    resolved_life_stage_group_names = [group.name] if group
  end
  # --- END LifeStageGroup Mapping ---

  resolved_life_stage_group_names = Array(resolved_life_stage_group_names).flatten.compact.uniq

  if resolved_life_stage_group_names.empty?
    puts "WARN: No LifeStageGroup mapping or direct match found for DRI value CSV name '#{life_stage_name_csv}'. Nutrient: #{nutrient.name}. Skipping. Row: #{row.to_h}"
    next
  end

  resolved_life_stage_group_names.each do |resolved_name|
    life_stage_group = Nutrition::LifeStageGroup.find_by(name: resolved_name)
    unless life_stage_group
      # This error means a name was "resolved" but doesn't actually exist in the DB.
      # Indicates an issue with the mapping logic itself or LifeStageGroup seeding.
      puts "ERROR: LifeStageGroup '#{resolved_name}' (resolved from CSV '#{life_stage_name_csv}') not found in DB. Nutrient: #{nutrient.name}. Row: #{row.to_h}"
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
    find_or_create_resource(Nutrition::DriValue, find_by_attrs.compact, update_attrs)
  end
end
puts "DRI Values seeded: #{Nutrition::DriValue.count}"


# 11. Dietary Pattern Components
puts "Seeding Dietary Pattern Components (Food Group Recommendations and Calorie Level Limits)..."
dietary_pattern_calorie_levels_cache = {} # Cache to avoid repeated DB lookups
dietary_pattern_food_group_recommendations_amount_value_nullable =
  Nutrition::DietaryPatternFoodGroupRecommendation.columns_hash['amount_value'].null # Check if amount_value can be null

CSV.foreach(Rails.root.join('db', 'data_sources', 'dietary_pattern_components.csv'), headers: true, header_converters: :symbol) do |row|
  dietary_pattern_name = row[:dietary_pattern_name]&.strip
  calorie_level_val = row[:calorie_level]&.strip&.to_i

  unless dietary_pattern_name && calorie_level_val
    puts "ERROR: Missing dietary_pattern_name or calorie_level in row: #{row.to_h}. Skipping."
    next
  end

  dietary_pattern = Nutrition::DietaryPattern.find_by(name: dietary_pattern_name)
  unless dietary_pattern
    puts "ERROR: DietaryPattern '#{dietary_pattern_name}' not found for row: #{row.to_h}. Skipping."
    next
  end

  dpcl_key = [dietary_pattern.id, calorie_level_val]
  dietary_pattern_calorie_level = dietary_pattern_calorie_levels_cache[dpcl_key]

  unless dietary_pattern_calorie_level
    dietary_pattern_calorie_level = Nutrition::DietaryPatternCalorieLevel.find_or_initialize_by(
      dietary_pattern_id: dietary_pattern.id,
      calorie_level: calorie_level_val
    )
    dietary_pattern_calorie_level.save! if dietary_pattern_calorie_level.new_record? || dietary_pattern_calorie_level.changed? # Save if new or changed
    dietary_pattern_calorie_levels_cache[dpcl_key] = dietary_pattern_calorie_level
  end

  component_name_val = row[:component_name]&.strip
  food_group_name_csv = row[:food_group_name]&.strip
  food_subgroup_name_csv = row[:food_subgroup_name]&.strip

  is_limit_row = component_name_val == "Limit on Calories for Other Uses" && food_group_name_csv.blank? && food_subgroup_name_csv.blank?

  if is_limit_row
    parsed_val = parse_amount_value(row[:amount_value])
    if row[:amount_unit]&.strip == "kcal"
      dietary_pattern_calorie_level.limit_on_calories_other_uses_kcal_day = parsed_val.present? ? parsed_val.to_i : nil
    elsif row[:amount_unit]&.strip == "%"
      dietary_pattern_calorie_level.limit_on_calories_other_uses_percent_day = parsed_val
    end
    dietary_pattern_calorie_level.save! if dietary_pattern_calorie_level.changed?
  else
    target_food_group_name = food_subgroup_name_csv.presence || food_group_name_csv.presence || component_name_val.presence
    if target_food_group_name.blank?
      puts "WARN: Dietary Pattern Component - Skipping row due to missing food group identifier. Row: #{row.to_h}"
      next
    end

    food_group = Nutrition::FoodGroup.find_by(name: target_food_group_name)
    unless food_group
      puts "WARN: Dietary Pattern Component - FoodGroup '#{target_food_group_name}' not found. CSV Row: #{row.to_h}. Skipping."
      next
    end

    parsed_numeric_amount = parse_amount_value(row[:amount_value])

    if parsed_numeric_amount.nil? && !dietary_pattern_food_group_recommendations_amount_value_nullable
      puts "WARN: Dietary Pattern Component - Parsed amount is nil but DB requires a value for FoodGroup '#{target_food_group_name}'. CSV Row: #{row.to_h}. Skipping recommendation."
      next
    end

    recommendation_attrs_to_update = {
      amount_value: parsed_numeric_amount,
      amount_frequency: row[:frequency].presence&.strip&.truncate(10),
    }
    recommendation_find_by = {
      dietary_pattern_calorie_level_id: dietary_pattern_calorie_level.id,
      food_group_id: food_group.id
    }
    find_or_create_resource(Nutrition::DietaryPatternFoodGroupRecommendation, recommendation_find_by, recommendation_attrs_to_update)
  end
end

puts "Dietary Pattern Calorie Levels processed: #{Nutrition::DietaryPatternCalorieLevel.count}"
puts "Dietary Pattern Food Group Recommendations seeded: #{Nutrition::DietaryPatternFoodGroupRecommendation.count}"


puts "--------------------------------"
puts "Seeding completed successfully!"
