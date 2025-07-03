module Seeding
  class FoundationalDataSeedingService
    def self.call
      new.call
    end

    def call
      seed_nutrients
      seed_life_stage_groups
      seed_food_groups
      seed_dietary_patterns
    end

    private

    def seed_nutrients
      puts "Seeding Nutrients..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'nutrients.csv'), headers: true, header_converters: :symbol) do |row|
        Helpers::ResourceFinder.find_or_create_resource(Nutrition::Nutrient, { dri_identifier: row[:dri_identifier]&.strip }, {
          name: row[:name]&.strip,
          category: row[:category]&.strip,
          default_unit: row[:default_unit]&.strip,
          analysis_unit: row[:analysis_unit]&.strip,
          conversion_factor: row[:conversion_factor].present? ? row[:conversion_factor].to_f : nil,
          description: row[:description].presence,
          sort_order: row[:sort_order].present? ? row[:sort_order].to_i : nil
        })
      end
      puts "Nutrients seeded: #{Nutrition::Nutrient.count}"
      # Diagnostic output for Nutrients
      puts "Sample Nutrient (Protein/PROCNT): #{Nutrition::Nutrient.find_by(dri_identifier: 'PROCNT')&.attributes.inspect}"
      puts "Sample Nutrient (Calcium/CA): #{Nutrition::Nutrient.find_by(dri_identifier: 'CA')&.attributes.inspect}"
      puts "Nutrient count with nil dri_identifier: #{Nutrition::Nutrient.where(dri_identifier: nil).count}"
    end

    def seed_life_stage_groups
      puts "Seeding Life Stage Groups..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'life_stages.csv'), headers: true, header_converters: :symbol) do |row|
        # Ensure max_age_months is correctly handled for blank values to avoid type errors with .to_i
        max_age_val = row[:max_age_months]
        # Default for open-ended max_age_months (e.g., "71+ years") is set to a high number (12000 months ~ 1000 years)
        # to signify no upper limit for practical purposes.
        max_age_months_int = max_age_val.present? && max_age_val.match?(/\A\d+\z/) ? max_age_val.to_i : 12000

        Helpers::ResourceFinder.find_or_create_resource(Nutrition::LifeStageGroup, { name: row[:name]&.strip }, {
          min_age_months: row[:min_age_months].to_i,
          max_age_months: max_age_months_int,
          sex: row[:sex]&.strip&.downcase,
          special_condition: row[:special_condition].presence&.strip,
          trimester: row[:trimester].present? ? row[:trimester].to_i : nil,
          lactation_period: (row[:lactation_period].present? && row[:lactation_period].strip.length <= 20 ? row[:lactation_period].strip : nil),
          notes: row[:notes].presence
        })
      end
      puts "Life Stage Groups seeded: #{Nutrition::LifeStageGroup.count}"
      output_life_stage_group_diagnostics
    end

    def seed_food_groups
      puts "Seeding Food Groups (Parents)..."
      parent_groups_map = {}
      CSV.foreach(Rails.root.join('db', 'data_sources', 'food_groups.csv'), headers: true, header_converters: :symbol) do |row|
        fg = Helpers::ResourceFinder.find_or_create_resource(Nutrition::FoodGroup, { name: row[:name]&.strip }, {
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
        Helpers::ResourceFinder.find_or_create_resource(Nutrition::FoodGroup, { name: row[:name]&.strip }, {
          parent_food_group_id: parent_id,
          default_unit_name: parent_food_group_for_subgroup.default_unit_name # Inherit default unit
        })
      end
      puts "Total Food Groups (incl. subgroups) seeded: #{Nutrition::FoodGroup.count}"
    end

    def seed_dietary_patterns
      puts "Seeding Dietary Patterns..."
      CSV.foreach(Rails.root.join('db', 'data_sources', 'dietary_patterns.csv'), headers: true, header_converters: :symbol) do |row|
        Helpers::ResourceFinder.find_or_create_resource(Nutrition::DietaryPattern, { name: row[:name]&.strip }, {
          description: row[:description].presence,
          source_document_reference: row[:source_document_reference].presence
        })
      end
      puts "Dietary Patterns seeded: #{Nutrition::DietaryPattern.count}"
    end

    def output_life_stage_group_diagnostics
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
    end
  end
end
