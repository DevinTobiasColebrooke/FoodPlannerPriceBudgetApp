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
Session.destroy_all # Assuming Session depends on User
User.destroy_all    # User destroyed before its direct dependencies

Goal.destroy_all
Allergy.destroy_all
DietaryRestriction.destroy_all
KitchenEquipment.destroy_all

Nutrient.destroy_all
FoodGroup.where.not(parent_food_group_id: nil).destroy_all # Delete children first
FoodGroup.where(parent_food_group_id: nil).destroy_all   # Then delete parents
DietaryPattern.destroy_all
LifeStageGroup.destroy_all

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

# 2. Life Stages (life_stages.csv -> LifeStageGroup model)
puts "Seeding Life Stage Groups..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'life_stages.csv'), headers: true, header_converters: :symbol) do |row|
  # Ensure max_age_months is correctly handled for blank values to avoid type errors with .to_i
  max_age_val = row[:max_age_months]
  # Default for open-ended max_age_months (e.g., "71+ years") is set to a high number (12000 months ~ 1000 years)
  # to signify no upper limit for practical purposes.
  max_age_months_int = max_age_val.present? && max_age_val.match?(/\A\d+\z/) ? max_age_val.to_i : 12000

  find_or_create_resource(LifeStageGroup, { name: row[:name]&.strip }, {
    min_age_months: row[:min_age_months].to_i,
    max_age_months: max_age_months_int,
    sex: row[:sex]&.strip&.downcase,
    special_condition: row[:special_condition].presence&.strip, # Uses presence to convert blank strings to nil
    trimester: row[:trimester].present? ? row[:trimester].to_i : nil,
    lactation_period: (row[:lactation_period].present? && row[:lactation_period].strip.length <= 20 ? row[:lactation_period].strip : nil), # Ensures within length limit
    notes: row[:notes].presence
  })
end
puts "Life Stage Groups seeded: #{LifeStageGroup.count}"

puts "--- Post LifeStageGroup Seeding Diagnostics ---"
puts "Distinct values for 'sex' in LifeStageGroup: #{LifeStageGroup.distinct.pluck(:sex).inspect}"
puts "Distinct values for 'special_condition' in LifeStageGroup: #{LifeStageGroup.distinct.pluck(:special_condition).inspect}"
puts "Count of LSGs with sex='male': #{LifeStageGroup.where(sex: 'male').count}"
puts "Count of LSGs with sex='female': #{LifeStageGroup.where(sex: 'female').count}"
puts "Count of LSGs with sex='any': #{LifeStageGroup.where(sex: 'any').count}"
puts "Count of LSGs with special_condition IS NULL: #{LifeStageGroup.where(special_condition: nil).count}"
puts "Count of LSGs with special_condition = '': #{LifeStageGroup.where(special_condition: '').count}"

puts "Sample 'Males 19-30 years' LSG: #{LifeStageGroup.find_by(name: 'Males 19-30 years')&.attributes.inspect}"
puts "Sample 'Children 4-8 years' LSG: #{LifeStageGroup.find_by(name: 'Children 4-8 years')&.attributes.inspect}"
puts "Sample 'Children 3 years' LSG: #{LifeStageGroup.find_by(name: 'Children 3 years')&.attributes.inspect}"
puts "--- End Post LifeStageGroup Seeding Diagnostics ---"

# 3. Food Groups (food_groups.csv & food_subgroups.csv for FoodGroup model)
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
  unless parent_id
    puts "ERROR: Parent FoodGroup '#{parent_name}' not found for subgroup '#{row[:name]&.strip}'. Skipping."
    next
  end

  parent_food_group_for_subgroup = FoodGroup.find(parent_id)
  find_or_create_resource(FoodGroup, { name: row[:name]&.strip }, {
    parent_food_group_id: parent_id,
    default_unit_name: parent_food_group_for_subgroup.default_unit_name # Inherit default unit
  })
end
puts "Total Food Groups (incl. subgroups) seeded: #{FoodGroup.count}"

# 4. Dietary Patterns (dietary_patterns.csv)
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
puts "Seeding EER Profiles..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_profiles.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group = LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?
  # EER Profiles are uniquely identified by name for simplicity in CSV, but ensure consistency.
  # If LifeStageGroup is meant to be part of uniqueness, add it to find_by_hash.
  find_or_create_resource(EerProfile, { name: row[:name]&.strip }, {
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
puts "EER Profiles seeded: #{EerProfile.count}"

# 6. EER Additive Components (eer_additive_components.csv)
puts "Seeding EER Additive Components..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_additive_components.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group = LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?

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
  find_or_create_resource(EerAdditiveComponent, find_by_attrs, update_attrs)
end
puts "EER Additive Components seeded: #{EerAdditiveComponent.count}"

# 7. Growth Factors (growth_factors.csv)
puts "Seeding Growth Factors..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'growth_factors.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_group_name_csv = row[:life_stage_group_id_placeholder]&.strip
  life_stage_group = LifeStageGroup.find_by(name: life_stage_group_name_csv)
  unless life_stage_group
    puts "WARN: LifeStageGroup '#{life_stage_group_name_csv}' not found for GrowthFactor. CSV Row: #{row.to_h}. Skipping."
    next
  end

  find_by_attrs = { life_stage_group_id: life_stage_group.id } # Assuming one growth factor per LSG
  update_attrs = {
    factor_value: row[:factor_value].to_f,
    source_document_reference: row[:source_document_reference].presence
  }
  find_or_create_resource(GrowthFactor, find_by_attrs, update_attrs)
end
puts "Growth Factors seeded: #{GrowthFactor.count}"

# 8. PAL Definitions (pal_definitions.csv)
puts "Seeding PAL Definitions..."

# Diagnostic: Check count for a known problematic query condition with more lenient special_condition check
# And ensure sex is queried in lowercase to match stored value
debug_gam_lsg_count = LifeStageGroup.where(sex: 'male') # Assuming 'male' is already lowercase from seeding
                                    .where(special_condition: [nil, ''])
                                    .where("min_age_months >= ?", 228)
                                    .count
puts "DEBUG (PAL section): Count of LSGs for 'General Adult Male' (male, >=228mo, spec_cond nil/''): #{debug_gam_lsg_count}"

debug_child_3_8_lsg_count = LifeStageGroup.where(special_condition: [nil, ''])
                                          .where("min_age_months >= 36 AND max_age_months <= 107") # 3 to <9 years
                                          .count
puts "DEBUG (PAL section): Count of LSGs for 'Children 3-8 years' (36-107mo, spec_cond nil/''): #{debug_child_3_8_lsg_count}"


CSV.foreach(Rails.root.join('db', 'data_sources', 'pal_definitions.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_name_from_csv = row[:life_stage_name]&.strip

  # Queries for LifeStageGroup should consistently use lowercase for sex
  # and [nil, ''] for special_condition where applicable.
  target_life_stage_group_names = case life_stage_name_from_csv
  when "General Adult Male"
    LifeStageGroup.where(sex: 'male')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= ?", 228)
                  .pluck(:name)
  when "General Adult Female"
    LifeStageGroup.where(sex: 'female')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= ?", 228)
                  .pluck(:name)
  when "General Boys 3-18 years"
    LifeStageGroup.where(sex: 'male')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= 36 AND max_age_months <= 227")
                  .pluck(:name)
  when "General Girls 3-18 years"
    LifeStageGroup.where(sex: 'female')
                  .where(special_condition: [nil, ''])
                  .where("min_age_months >= 36 AND max_age_months <= 227")
                  .pluck(:name)
  # ... (ensure all other case branches also use sex: 'male'/'female' in lowercase and special_condition: [nil, ''])
  when "Children 3-8 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= 36 AND max_age_months <= 107")
                  .pluck(:name)
  when "Children 9-13 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= 108 AND max_age_months <= 167")
                  .pluck(:name)
  when "Adolescents 14-18 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= 168 AND max_age_months <= 227")
                  .pluck(:name)
  when "Adults 19+ years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where("min_age_months >= ?", 228)
                  .pluck(:name)
  when "Infants 0-6 months" # These typically don't have sex-specific general PALs, but rely on name
      LifeStageGroup.where(name: "Infants 0-6 months").pluck(:name)
  when "Infants 7-12 months"
      LifeStageGroup.where(name: "Infants 7-12 months").pluck(:name)
  when "Children 1-3 years"
      LifeStageGroup.where(name: "Children 1-3 years").pluck(:name)
  when "Children 4-8 years" # This maps to the specific LifeStageGroup from CSV named "Children 4-8 years"
                            # and other relevant groups.
      LifeStageGroup.where(name: "Children 4-8 years") # Direct name match
                  .or(LifeStageGroup.where(special_condition: [nil, '']) # Broader match for other 'any' sex groups
                                    .where(sex: ['any', 'male', 'female']) # Be explicit if needed
                                    .where("min_age_months >= 48 AND max_age_months <= 107"))
                  .pluck(:name).uniq
  when "Adults 19-30 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female']) # Assuming these can apply to 'any' sex groups if not gender specific
                  .where("min_age_months >= 228 AND max_age_months <= 371")
                  .pluck(:name)
  when "Adults 31-50 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 372 AND max_age_months <= 611")
                  .pluck(:name)
  when "Adults 51-70 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 612 AND max_age_months <= 851")
                  .pluck(:name)
  when "Children 0-2.99 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 0 AND max_age_months <= 35")
                  .pluck(:name)
  when "Children 3-8.99 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female']) # PALs for "Children" often apply to both sexes if not specified
                  .where("min_age_months >= 36 AND max_age_months <= 107")
                  .pluck(:name)
  when "Children 9-13.99 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 108 AND max_age_months <= 167")
                  .pluck(:name)
  when "Adolescents 14-18.99 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 168 AND max_age_months <= 227")
                  .pluck(:name)
  when "Adults 19-70.99 years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 228 AND max_age_months <= 851")
                  .pluck(:name)
  when "Adults 71+ years"
    LifeStageGroup.where(special_condition: [nil, ''])
                  .where(sex: ['any', 'male', 'female'])
                  .where("min_age_months >= 852")
                  .pluck(:name)
  else
    # Fallback for direct match by name if not covered above
    existing_group = LifeStageGroup.find_by(name: life_stage_name_from_csv)
    target_life_stage_group_names = existing_group ? [existing_group.name] : []
  end

  if target_life_stage_group_names.empty?
    puts "WARN: No LifeStageGroup found for PAL Definition mapping: '#{life_stage_name_from_csv}'. Skipping PAL entry: #{row.to_h}"
    next
  end

  target_life_stage_group_names.uniq.each do |resolved_lsg_name|
    life_stage_group = LifeStageGroup.find_by(name: resolved_lsg_name)
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

    find_or_create_resource(PalDefinition, find_by_attrs, update_attrs)
  end
end
puts "PAL Definitions seeded: #{PalDefinition.count}"

# 9. Reference Anthropometries (reference_anthropometries.csv)
puts "Seeding Reference Anthropometries..."
CSV.foreach(Rails.root.join('db', 'data_sources', 'reference_anthropometries.csv'), headers: true, header_converters: :symbol) do |row|
  life_stage_name_csv = row[:life_stage_group_id_placeholder]&.strip
  # Simplified mapping for reference anthropometries, assuming direct names for now
  life_stage_group = LifeStageGroup.find_by(name: life_stage_name_csv)
  unless life_stage_group
    puts "WARN: Reference Anthropometry - LifeStageGroup '#{life_stage_name_csv}' not found. Skipping. CSV Row: #{row.to_h}"
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
  # Basic mapping for nutrient identifiers, add more if needed
  db_nutrient_identifier = case nutrient_identifier_csv
    when "BIOTIN" then "BIOT"
    when "/CU" then "CU"
    when "VANADIUM" then "VANAD"
    else nutrient_identifier_csv
  end

  nutrient = Nutrient.find_by(dri_identifier: db_nutrient_identifier)
  life_stage_name_csv = row[:life_stage_name]&.strip

  # Similar broad to specific mapping as PAL definitions
  resolved_life_stage_group_names = case life_stage_name_csv
    when "Males >18 years" then LifeStageGroup.where(sex: 'male').where("min_age_months >= ?", 228).where(special_condition: nil).pluck(:name)
    when "Females >18 years" then LifeStageGroup.where(sex: 'female').where("min_age_months >= ?", 228).where(special_condition: nil).pluck(:name)
    when "Adolescents 9-18 years" then LifeStageGroup.where(min_age_months: 108..227, special_condition: nil).pluck(:name)
    when "Adults >=19 years" then LifeStageGroup.where("min_age_months >= 228 AND special_condition IS NULL").pluck(:name)
    # Specific mappings for pregnancy/lactation
    when "Pregnancy (all ages)", "Pregnancy 14-50 years" then LifeStageGroup.where(special_condition: 'pregnancy').pluck(:name)
    when "Lactation (all ages)", "Lactation 14-50 years" then LifeStageGroup.where(special_condition: 'lactation').pluck(:name)
    when "Pregnancy <=18 years", "Pregnancy 14-18 years" then LifeStageGroup.where(special_condition: 'pregnancy', min_age_months: 168..227).pluck(:name)
    when "Pregnancy >=19 years", "Pregnancy 19-50 years" then LifeStageGroup.where(special_condition: 'pregnancy').where("min_age_months >= 228").pluck(:name)
    when "Lactation <=18 years", "Lactation 14-18 years" then LifeStageGroup.where(special_condition: 'lactation', min_age_months: 168..227).pluck(:name)
    when "Lactation >=19 years", "Lactation 19-50 years" then LifeStageGroup.where(special_condition: 'lactation').where("min_age_months >= 228").pluck(:name)
    else
      direct_match = LifeStageGroup.find_by(name: life_stage_name_csv)
      direct_match ? [direct_match.name] : []
    end
  resolved_life_stage_group_names.compact!

  unless nutrient
    puts "WARN: Nutrient with original DRI ID '#{nutrient_identifier_csv}' (mapped to '#{db_nutrient_identifier}') not found. Skipping DRI value. Row: #{row.to_h}"
    next
  end

  if resolved_life_stage_group_names.empty?
    puts "WARN: No LifeStageGroup mapping or direct match found for DRI value CSV name '#{life_stage_name_csv}'. Nutrient: #{nutrient.name}. Skipping."
    next
  end

  resolved_life_stage_group_names.each do |resolved_name|
    next if resolved_name.blank?
    life_stage_group = LifeStageGroup.find_by(name: resolved_name)
    unless life_stage_group
      puts "ERROR: LifeStageGroup '#{resolved_name}' (resolved from CSV '#{life_stage_name_csv}') not found. Nutrient: #{nutrient.name}. Row: #{row.to_h}"
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
    find_or_create_resource(DriValue, find_by_attrs.compact, update_attrs)
  end
end
puts "DRI Values seeded: #{DriValue.count}"


# 11. Dietary Pattern Components
puts "Seeding Dietary Pattern Components (Food Group Recommendations and Calorie Level Limits)..."
dietary_pattern_calorie_levels_cache = {} # Cache to avoid repeated DB lookups
dietary_pattern_food_group_recommendations_amount_value_nullable =
  DietaryPatternFoodGroupRecommendation.columns_hash['amount_value'].null # Check if amount_value can be null

CSV.foreach(Rails.root.join('db', 'data_sources', 'dietary_pattern_components.csv'), headers: true, header_converters: :symbol) do |row|
  dietary_pattern_name = row[:dietary_pattern_name]&.strip
  calorie_level_val = row[:calorie_level]&.strip&.to_i

  unless dietary_pattern_name && calorie_level_val
    puts "ERROR: Missing dietary_pattern_name or calorie_level in row: #{row.to_h}. Skipping."
    next
  end

  dietary_pattern = DietaryPattern.find_by(name: dietary_pattern_name)
  unless dietary_pattern
    puts "ERROR: DietaryPattern '#{dietary_pattern_name}' not found for row: #{row.to_h}. Skipping."
    next
  end

  dpcl_key = [dietary_pattern.id, calorie_level_val]
  dietary_pattern_calorie_level = dietary_pattern_calorie_levels_cache[dpcl_key]

  unless dietary_pattern_calorie_level
    dietary_pattern_calorie_level = DietaryPatternCalorieLevel.find_or_initialize_by(
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

    food_group = FoodGroup.find_by(name: target_food_group_name)
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
    find_or_create_resource(DietaryPatternFoodGroupRecommendation, recommendation_find_by, recommendation_attrs_to_update)
  end
end

puts "Dietary Pattern Calorie Levels processed: #{DietaryPatternCalorieLevel.count}"
puts "Dietary Pattern Food Group Recommendations seeded: #{DietaryPatternFoodGroupRecommendation.count}"


puts "--------------------------------"
puts "Seeding completed successfully!"
