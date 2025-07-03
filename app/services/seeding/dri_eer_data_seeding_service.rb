module Seeding
  class DriEerDataSeedingService
    def self.call
      new.call
    end

    def call
      seed_eer_profiles
      seed_eer_additive_components
      seed_growth_factors
      seed_pal_definitions
      seed_reference_anthropometries
      seed_dri_values
      seed_dietary_pattern_components
    end

    private

    def seed_eer_profiles
      puts "Seeding EER Profiles..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_profiles.csv'), headers: true, header_converters: :symbol) do |row|
        life_stage_group = Nutrition::LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?
        Helpers::ResourceFinder.find_or_create_resource(Nutrition::EerProfile, { name: row[:name]&.strip }, {
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
      puts "EER Profiles seeded: #{Nutrition::EerProfile.count}"
    end

    def seed_eer_additive_components
      puts "Seeding EER Additive Components..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'eer_additive_components.csv'), headers: true, header_converters: :symbol) do |row|
        life_stage_group = Nutrition::LifeStageGroup.find_by(name: row[:life_stage_group_id_placeholder]&.strip) if row[:life_stage_group_id_placeholder].present?

        find_by_attrs = {
          component_type: row[:component_type]&.strip,
          life_stage_group_id: life_stage_group&.id,
          sex_filter: row[:sex_filter].presence&.strip,
          age_min_months_filter: row[:age_min_months_filter].present? ? row[:age_min_months_filter].to_i : nil,
          age_max_months_filter: row[:age_max_months_filter].present? ? row[:age_max_months_filter].to_i : nil,
          condition_pregnancy_trimester_filter: row[:condition_pregnancy_trimester_filter].present? ? row[:condition_pregnancy_trimester_filter].to_i : nil,
          condition_pre_pregnancy_bmi_category_filter: row[:condition_pre_pregnancy_bmi_category_filter].presence&.strip,
          condition_lactation_period_filter: row[:condition_lactation_period_filter].presence&.strip&.truncate(20)
        }
        find_by_attrs.compact!

        update_attrs = {
          value_kcal_day: row[:value_kcal_day].to_i,
          notes: row[:notes].presence,
          source_document_reference: row[:source_document_reference].presence
        }
        Helpers::ResourceFinder.find_or_create_resource(Nutrition::EerAdditiveComponent, find_by_attrs, update_attrs)
      end
      puts "EER Additive Components seeded: #{Nutrition::EerAdditiveComponent.count}"
    end

    def seed_growth_factors
      puts "Seeding Growth Factors..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'growth_factors.csv'), headers: true, header_converters: :symbol) do |row|
        life_stage_group_name_csv = row[:life_stage_group_id_placeholder]&.strip
        life_stage_group = Nutrition::LifeStageGroup.find_by(name: life_stage_group_name_csv)
        unless life_stage_group
          puts "WARN: LifeStageGroup '#{life_stage_group_name_csv}' not found for GrowthFactor. CSV Row: #{row.to_h}. Skipping."
          next
        end

        find_by_attrs = { life_stage_group_id: life_stage_group.id }
        update_attrs = {
          factor_value: row[:factor_value].to_f,
          source_document_reference: row[:source_document_reference].presence
        }
        Helpers::ResourceFinder.find_or_create_resource(Nutrition::GrowthFactor, find_by_attrs, update_attrs)
      end
      puts "Growth Factors seeded: #{Nutrition::GrowthFactor.count}"
    end

    def seed_pal_definitions
      puts "Seeding PAL Definitions..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'pal_definitions.csv'), headers: true, header_converters: :symbol) do |row|
        life_stage_name_from_csv = row[:life_stage_name]&.strip
        target_life_stage_group_names = resolve_life_stage_groups(life_stage_name_from_csv)

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

          Helpers::ResourceFinder.find_or_create_resource(Nutrition::PalDefinition, find_by_attrs, update_attrs)
        end
      end
      puts "PAL Definitions seeded: #{Nutrition::PalDefinition.count}"
    end

    def seed_reference_anthropometries
      puts "Seeding Reference Anthropometries..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'reference_anthropometries.csv'), headers: true, header_converters: :symbol) do |row|
        life_stage_name_csv = row[:life_stage_group_id_placeholder]&.strip
        resolved_lsg_names = resolve_reference_anthropometry_life_stage_groups(life_stage_name_csv)

        if resolved_lsg_names.empty?
          puts "WARN: Reference Anthropometry - LifeStageGroup placeholder '#{life_stage_name_csv}' did not map to any known LifeStageGroups. Skipping. CSV Row: #{row.to_h}"
          next
        end

        resolved_lsg_names.each do |lsg_name|
          life_stage_group = Nutrition::LifeStageGroup.find_by(name: lsg_name)
          unless life_stage_group
            puts "ERROR: Reference Anthropometry - Resolved LifeStageGroup name '#{lsg_name}' (from CSV placeholder '#{life_stage_name_csv}') not found in database. Skipping this specific entry."
            next
          end

          Helpers::ResourceFinder.find_or_create_resource(Nutrition::ReferenceAnthropometry, { life_stage_group_id: life_stage_group.id }, {
            reference_height_cm: row[:reference_height_cm].present? ? row[:reference_height_cm].to_f : nil,
            reference_weight_kg: row[:reference_weight_kg].present? ? row[:reference_weight_kg].to_f : nil,
            median_bmi: row[:median_bmi].present? ? row[:median_bmi].to_f : nil,
            source_document_reference: row[:source_document_reference].presence
          })
        end
      end
      puts "Reference Anthropometries seeded: #{Nutrition::ReferenceAnthropometry.count}"
    end

    def seed_dri_values
      puts "Seeding DRI Values..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'dri_values.csv'), headers: true, header_converters: :symbol) do |row|
        nutrient_identifier_csv = row[:nutrient_identifier]&.strip
        db_nutrient_identifier = map_nutrient_identifier(nutrient_identifier_csv)

        nutrient = Nutrition::Nutrient.find_by(dri_identifier: db_nutrient_identifier)
        life_stage_name_csv = row[:life_stage_name]&.strip

        unless nutrient
          puts "WARN: Nutrient with original DRI ID '#{nutrient_identifier_csv}' (mapped to DB ID '#{db_nutrient_identifier}') not found. Skipping DRI value. Row: #{row.to_h}"
          next
        end

        if life_stage_name_csv.blank?
          puts "WARN: DRI Value - CSV row has blank life_stage_name. Nutrient: #{nutrient.name}. Skipping. Row: #{row.to_h}"
          next
        end

        resolved_life_stage_group_names = resolve_dri_life_stage_groups(life_stage_name_csv)
        resolved_life_stage_group_names = Array(resolved_life_stage_group_names).flatten.compact.uniq

        if resolved_life_stage_group_names.empty?
          puts "WARN: No LifeStageGroup mapping or direct match found for DRI value CSV name '#{life_stage_name_csv}'. Nutrient: #{nutrient.name}. Skipping. Row: #{row.to_h}"
          next
        end

        resolved_life_stage_group_names.each do |resolved_name|
          life_stage_group = Nutrition::LifeStageGroup.find_by(name: resolved_name)
          unless life_stage_group
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
          Helpers::ResourceFinder.find_or_create_resource(Nutrition::DriValue, find_by_attrs.compact, update_attrs)
        end
      end
      puts "DRI Values seeded: #{Nutrition::DriValue.count}"
    end

    def seed_dietary_pattern_components
      puts "Seeding Dietary Pattern Components (Food Group Recommendations and Calorie Level Limits)..."
      dietary_pattern_calorie_levels_cache = {}
      dietary_pattern_food_group_recommendations_amount_value_nullable =
        Nutrition::DietaryPatternCalorieLevel.columns_hash['amount_value'].null

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
          dietary_pattern_calorie_level.save! if dietary_pattern_calorie_level.new_record? || dietary_pattern_calorie_level.changed?
          dietary_pattern_calorie_levels_cache[dpcl_key] = dietary_pattern_calorie_level
        end

        component_name_val = row[:component_name]&.strip
        food_group_name_csv = row[:food_group_name]&.strip
        food_subgroup_name_csv = row[:food_subgroup_name]&.strip

        is_limit_row = component_name_val == "Limit on Calories for Other Uses" && food_group_name_csv.blank? && food_subgroup_name_csv.blank?

        if is_limit_row
          parsed_val = Helpers::AmountParser.parse_amount_value(row[:amount_value])
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

          parsed_numeric_amount = Helpers::AmountParser.parse_amount_value(row[:amount_value])

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
          Helpers::ResourceFinder.find_or_create_resource(Nutrition::DietaryPatternFoodGroupRecommendation, recommendation_find_by, recommendation_attrs_to_update)
        end
      end

      puts "Dietary Pattern Calorie Levels processed: #{Nutrition::DietaryPatternCalorieLevel.count}"
      puts "Dietary Pattern Food Group Recommendations seeded: #{Nutrition::DietaryPatternFoodGroupRecommendation.count}"
    end

    private

    def map_nutrient_identifier(identifier)
      case identifier
      when "BIOTIN" then "BIOT"
      when "/CU" then "CU"
      when "VANADIUM" then "VANAD"
      else identifier
      end
    end

    def resolve_life_stage_groups(life_stage_name)
      # Implementation of life stage group resolution logic
      # This is a placeholder - you'll need to implement the full logic from the original seeds.rb
      []
    end

    def resolve_reference_anthropometry_life_stage_groups(life_stage_name)
      # Implementation of reference anthropometry life stage group resolution logic
      # This is a placeholder - you'll need to implement the full logic from the original seeds.rb
      []
    end

    def resolve_dri_life_stage_groups(life_stage_name)
      # Implementation of DRI life stage group resolution logic
      # This is a placeholder - you'll need to implement the full logic from the original seeds.rb
      []
    end
  end
end
