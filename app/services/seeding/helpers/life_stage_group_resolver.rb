module Seeding
  module Helpers
    module LifeStageGroupResolver
      def self.resolve_life_stage_groups(life_stage_name)
        case life_stage_name
        # Category 1: Exact or near-exact matches to LifeStageGroup names from life_stages.csv
        when "Infants 0-6 months", "Infants 7-12 months", "Toddlers 12-23 months", "Children 1-3 years", "Children 2-3 years",
             "Females 4-8 years", "Males 4-8 years", "Females 9-13 years", "Males 9-13 years",
             "Females 14-18 years", "Males 14-18 years", "Females 19-30 years", "Males 19-30 years",
             "Females 31-50 years", "Males 31-50 years", "Females 51+ years", "Males 51+ years",
             "Females 71+ years", "Males 71+ years",
             "Pregnancy 14-18 years 1st Trimester", "Pregnancy 14-18 years 2nd Trimester", "Pregnancy 14-18 years 3rd Trimester",
             "Pregnancy 19-30 years 1st Trimester", "Pregnancy 19-30 years 2nd Trimester", "Pregnancy 19-30 years 3rd Trimester",
             "Pregnancy 31-50 years 1st Trimester", "Pregnancy 31-50 years 2nd Trimester", "Pregnancy 31-50 years 3rd Trimester",
             "Lactation 14-18 years 0-6 months", "Lactation 14-18 years 7-12 months",
             "Lactation 19-30 years 0-6 months", "Lactation 19-30 years 7-12 months",
             "Lactation 31-50 years 0-6 months", "Lactation 31-50 years 7-12 months"
          # For these, the CSV name is expected to be a direct LifeStageGroup name
          group = Nutrition::LifeStageGroup.find_by(name: life_stage_name)
          [group.name] if group

        # Category 2: Common DRI groupings that imply Male + Female counterparts
        when "Children 4-8 years" # General term implies all relevant groups
          Nutrition::LifeStageGroup.where(name: ["Children 4-8 years", "Males 4-8 years", "Females 4-8 years"]).pluck(:name)
        when "Children 9-13 years", "Boys 9-13 years", "Girls 9-13 years" # Includes sex-specific synonyms
          # If "Children 9-13 years" appears, map to both. If "Boys..." or "Girls...", map to specific.
          if life_stage_name == "Children 9-13 years"
            Nutrition::LifeStageGroup.where(name: ["Males 9-13 years", "Females 9-13 years"]).pluck(:name)
          elsif life_stage_name == "Boys 9-13 years"
            Nutrition::LifeStageGroup.where(name: "Males 9-13 years").pluck(:name)
          elsif life_stage_name == "Girls 9-13 years"
            Nutrition::LifeStageGroup.where(name: "Females 9-13 years").pluck(:name)
          end
        when "Adolescents 14-18 years"
          Nutrition::LifeStageGroup.where(name: ["Males 14-18 years", "Females 14-18 years"]).pluck(:name)
        when "Adults 19-30 years", "Men 19-30 years", "Women 19-30 years"
          if life_stage_name == "Adults 19-30 years"
            Nutrition::LifeStageGroup.where(name: ["Males 19-30 years", "Females 19-30 years"]).pluck(:name)
          elsif life_stage_name == "Men 19-30 years"
            Nutrition::LifeStageGroup.where(name: "Males 19-30 years").pluck(:name)
          elsif life_stage_name == "Women 19-30 years"
            Nutrition::LifeStageGroup.where(name: "Females 19-30 years").pluck(:name)
          end
        when "Adults 31-50 years", "Men 31-50 years", "Women 31-50 years"
          if life_stage_name == "Adults 31-50 years"
            Nutrition::LifeStageGroup.where(name: ["Males 31-50 years", "Females 31-50 years"]).pluck(:name)
          elsif life_stage_name == "Men 31-50 years"
            Nutrition::LifeStageGroup.where(name: "Males 31-50 years").pluck(:name)
          elsif life_stage_name == "Women 31-50 years"
            Nutrition::LifeStageGroup.where(name: "Females 31-50 years").pluck(:name)
          end
        when "Adults 51-70 years", "Males 51-70 years", "Females 51-70 years", "Men 51-70 years", "Women 51-70 years"
          if life_stage_name == "Adults 51-70 years"
            Nutrition::LifeStageGroup.where(name: ["Males 51-70 years", "Females 51-70 years"]).pluck(:name)
          elsif life_stage_name == "Males 51-70 years" || life_stage_name == "Men 51-70 years"
            Nutrition::LifeStageGroup.where(name: "Males 51-70 years").pluck(:name)
          elsif life_stage_name == "Females 51-70 years" || life_stage_name == "Women 51-70 years"
            Nutrition::LifeStageGroup.where(name: "Females 51-70 years").pluck(:name)
          end
        when "Adults >70 years", "Men >70 years", "Women >70 years"
          if life_stage_name == "Adults >70 years"
            Nutrition::LifeStageGroup.where(name: ["Males 71+ years", "Females 71+ years"]).pluck(:name)
          elsif life_stage_name == "Men >70 years"
            Nutrition::LifeStageGroup.where(name: "Males 71+ years").pluck(:name)
          elsif life_stage_name == "Women >70 years"
            Nutrition::LifeStageGroup.where(name: "Females 71+ years").pluck(:name)
          end
        when "Males >70 years"
          Nutrition::LifeStageGroup.where(name: "Males 71+ years").pluck(:name)
        when "Females >70 years"
          Nutrition::LifeStageGroup.where(name: "Females 71+ years").pluck(:name)

        # Category 3: Broader Age/Sex Categories or Special Conditions
        when "Pregnancy <=18 years", "Pregnancy 14-18 years"
          Nutrition::LifeStageGroup.where(name: [
            "Pregnancy 14-18 years 1st Trimester", "Pregnancy 14-18 years 2nd Trimester", "Pregnancy 14-18 years 3rd Trimester"
          ]).pluck(:name)
        when "Pregnancy 19-30 years"
          Nutrition::LifeStageGroup.where(name: [
            "Pregnancy 19-30 years 1st Trimester", "Pregnancy 19-30 years 2nd Trimester", "Pregnancy 19-30 years 3rd Trimester"
          ]).pluck(:name)
        when "Pregnancy 31-50 years"
          Nutrition::LifeStageGroup.where(name: [
            "Pregnancy 31-50 years 1st Trimester", "Pregnancy 31-50 years 2nd Trimester", "Pregnancy 31-50 years 3rd Trimester"
          ]).pluck(:name)
        when "Pregnancy 19-50 years", "Pregnancy >=19 years"
          Nutrition::LifeStageGroup.where(special_condition: 'pregnancy').where(name: [
            "Pregnancy 19-30 years 1st Trimester", "Pregnancy 19-30 years 2nd Trimester", "Pregnancy 19-30 years 3rd Trimester",
            "Pregnancy 31-50 years 1st Trimester", "Pregnancy 31-50 years 2nd Trimester", "Pregnancy 31-50 years 3rd Trimester"
          ]).pluck(:name)
        when "Pregnancy 14-50 years", "Pregnancy (all ages)"
          Nutrition::LifeStageGroup.where(special_condition: 'pregnancy').pluck(:name)

        when "Lactation <=18 years", "Lactation 14-18 years"
          Nutrition::LifeStageGroup.where(name: [
            "Lactation 14-18 years 0-6 months", "Lactation 14-18 years 7-12 months"
          ]).pluck(:name)
        when "Lactation 19-30 years"
          Nutrition::LifeStageGroup.where(name: [
            "Lactation 19-30 years 0-6 months", "Lactation 19-30 years 7-12 months"
          ]).pluck(:name)
        when "Lactation 31-50 years"
          Nutrition::LifeStageGroup.where(name: [
            "Lactation 31-50 years 0-6 months", "Lactation 31-50 years 7-12 months"
          ]).pluck(:name)
        when "Lactation 19-50 years", "Lactation >=19 years"
          Nutrition::LifeStageGroup.where(special_condition: 'lactation').where(name: [
            "Lactation 19-30 years 0-6 months", "Lactation 19-30 years 7-12 months",
            "Lactation 31-50 years 0-6 months", "Lactation 31-50 years 7-12 months"
          ]).pluck(:name)
        when "Lactation 14-50 years", "Lactation (all ages)"
          Nutrition::LifeStageGroup.where(special_condition: 'lactation').pluck(:name)

        # Ranges spanning multiple standard groups
        when "Males 19-70 years"
          Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                  .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 851).pluck(:name)
        when "Females 19-70 years"
          Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                  .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 851).pluck(:name)
        when "Adolescents 9-18 years"
          Nutrition::LifeStageGroup.where(name: [
            "Males 9-13 years", "Females 9-13 years", "Males 14-18 years", "Females 14-18 years"
          ]).pluck(:name)
        when "Adults 19-70 years"
          Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                  .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 851).pluck(:name)
        when "Adults >=19 years", "Adults >18 years"
          Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 228).pluck(:name)
        when "Males >18 years", "Males >=19 years", "Males >19 years"
          Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 228).pluck(:name)
        when "Females >18 years", "Females >=19 years", "Females >19 years"
          Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 228).pluck(:name)
        when "Adults 19-50 years"
          Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                  .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 611).pluck(:name)
        when "Males 19-50 years"
          Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                  .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 611).pluck(:name)
        when "Females 19-50 years"
          Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                  .where("min_age_months >= ? AND COALESCE(max_age_months, 12000) <= ?", 228, 611).pluck(:name)
        when "Males >=51 years"
          Nutrition::LifeStageGroup.where(sex: 'male', special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 612).pluck(:name)
        when "Females >=51 years"
          Nutrition::LifeStageGroup.where(sex: 'female', special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 612).pluck(:name)
        when "Adults >=51 years"
          Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 612).pluck(:name)
        when "Adults >=31 years"
          Nutrition::LifeStageGroup.where(sex: ['male', 'female'], special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 372).pluck(:name)
        when "Children 4-13 years"
          Nutrition::LifeStageGroup.where(name: [
            "Children 4-8 years", "Males 4-8 years", "Females 4-8 years",
            "Males 9-13 years", "Females 9-13 years"
          ]).pluck(:name)
        when "Infants 0-12 months"
          Nutrition::LifeStageGroup.where(name: ["Infants 0-6 months", "Infants 7-12 months"]).pluck(:name)

        # Category 4: Fallback for any unhandled exact matches
        else
          # This is a safety net. Ideally, all CSV values should be explicitly handled above.
          group = Nutrition::LifeStageGroup.find_by(name: life_stage_name)
          [group.name] if group
        end
      end

      def self.resolve_reference_anthropometry_life_stage_groups(life_stage_name)
        case life_stage_name
        when "Adult Males Reference"
          ["Males 19-30 years"]
        when "Adult Females Reference"
          ["Females 19-30 years"]
        when "Infants 2-6 months"
          ["Infants 0-6 months"]
        when "Infants 7-11 months"
          ["Infants 7-12 months"]
        when "Children 1-3 years"
          ["Children 1-3 years"]
        when "Children 4-8 years"
          ["Children 4-8 years", "Males 4-8 years", "Females 4-8 years"]
        when "Males 9-13 years"
          ["Males 9-13 years"]
        when "Males 14-18 years"
          ["Males 14-18 years"]
        when "Males 19-30 years"
          ["Males 19-30 years"]
        when "Females 9-13 years"
          ["Females 9-13 years"]
        when "Females 14-18 years"
          ["Females 14-18 years"]
        when "Females 19-30 years"
          ["Females 19-30 years"]
        when "Infants 0-11 months DLW"
          ["Infants 0-6 months", "Infants 7-12 months"]
        when "Children 1-8 years DLW"
          Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                                  .where("min_age_months <= ? AND COALESCE(max_age_months, 12000) >= ?", 107, 12)
                                  .pluck(:name)
        when "Children 9-18 years DLW"
          Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                                  .where("min_age_months <= ? AND COALESCE(max_age_months, 12000) >= ?", 227, 108)
                                  .pluck(:name)
        when "Adults 19+ years DLW"
          Nutrition::LifeStageGroup.where(special_condition: [nil, ''])
                                  .where("min_age_months >= ?", 228)
                                  .pluck(:name)
        when "Pregnant/Lactating Women DLW"
          Nutrition::LifeStageGroup.where(sex: 'female')
                                  .where(special_condition: ['pregnancy', 'lactation'])
                                  .pluck(:name)
        else
          group = Nutrition::LifeStageGroup.find_by(name: life_stage_name)
          [group.name] if group
        end
      end

      def self.resolve_dri_life_stage_groups(life_stage_name)
        resolve_life_stage_groups(life_stage_name)
      end
    end
  end
end
