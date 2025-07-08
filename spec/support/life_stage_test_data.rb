module LifeStageTestData
  # Representative life stage categories for comprehensive testing
  LIFE_STAGE_CATEGORIES = {
    # Infants
    infant_0_6_months: {
      age_in_months: 3,
      sex: 'any',
      weight_kg: 6.0,
      height_cm: 60.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    infant_7_12_months: {
      age_in_months: 9,
      sex: 'any',
      weight_kg: 9.0,
      height_cm: 72.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    # Children
    toddler_12_23_months: {
      age_in_months: 18,
      sex: 'any',
      weight_kg: 11.0,
      height_cm: 82.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    child_1_3_years: {
      age_in_months: 24,
      sex: 'any',
      weight_kg: 13.0,
      height_cm: 90.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    child_4_8_years: {
      age_in_months: 60,
      sex: 'any',
      weight_kg: 20.0,
      height_cm: 110.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    # Adolescents
    female_9_13_years: {
      age_in_months: 120,
      sex: 'female',
      weight_kg: 35.0,
      height_cm: 145.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    male_9_13_years: {
      age_in_months: 120,
      sex: 'male',
      weight_kg: 38.0,
      height_cm: 148.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    female_14_18_years: {
      age_in_months: 180,
      sex: 'female',
      weight_kg: 55.0,
      height_cm: 162.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    male_14_18_years: {
      age_in_months: 180,
      sex: 'male',
      weight_kg: 65.0,
      height_cm: 175.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    # Adults
    female_19_30_years: {
      age_in_months: 240,
      sex: 'female',
      weight_kg: 60.0,
      height_cm: 165.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    male_19_30_years: {
      age_in_months: 240,
      sex: 'male',
      weight_kg: 75.0,
      height_cm: 178.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    female_31_50_years: {
      age_in_months: 420,
      sex: 'female',
      weight_kg: 65.0,
      height_cm: 165.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    male_31_50_years: {
      age_in_months: 420,
      sex: 'male',
      weight_kg: 80.0,
      height_cm: 178.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    # Older Adults
    female_51_70_years: {
      age_in_months: 600,
      sex: 'female',
      weight_kg: 68.0,
      height_cm: 163.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    male_51_70_years: {
      age_in_months: 600,
      sex: 'male',
      weight_kg: 82.0,
      height_cm: 176.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    female_71_plus_years: {
      age_in_months: 900,
      sex: 'female',
      weight_kg: 65.0,
      height_cm: 160.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    male_71_plus_years: {
      age_in_months: 900,
      sex: 'male',
      weight_kg: 78.0,
      height_cm: 173.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: false
    },

    # Pregnancy scenarios
    pregnant_female_19_30_1st_trimester: {
      age_in_months: 240,
      sex: 'female',
      weight_kg: 60.0,
      height_cm: 165.0,
      physical_activity_level: 'sedentary',
      is_pregnant: true,
      is_lactating: false
    },

    pregnant_female_19_30_2nd_trimester: {
      age_in_months: 240,
      sex: 'female',
      weight_kg: 62.0,
      height_cm: 165.0,
      physical_activity_level: 'sedentary',
      is_pregnant: true,
      is_lactating: false
    },

    pregnant_female_19_30_3rd_trimester: {
      age_in_months: 240,
      sex: 'female',
      weight_kg: 65.0,
      height_cm: 165.0,
      physical_activity_level: 'sedentary',
      is_pregnant: true,
      is_lactating: false
    },

    # Lactation scenarios
    lactating_female_19_30_0_6_months: {
      age_in_months: 240,
      sex: 'female',
      weight_kg: 62.0,
      height_cm: 165.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: true
    },

    lactating_female_19_30_7_12_months: {
      age_in_months: 240,
      sex: 'female',
      weight_kg: 61.0,
      height_cm: 165.0,
      physical_activity_level: 'sedentary',
      is_pregnant: false,
      is_lactating: true
    }
  }.freeze

  # Helper method to create OpenStruct from life stage data
  def self.create_user_input(life_stage_key)
    data = LIFE_STAGE_CATEGORIES[life_stage_key]
    raise ArgumentError, "Unknown life stage: #{life_stage_key}" unless data

    OpenStruct.new(data)
  end

  # Helper method to get all life stage keys
  def self.life_stage_keys
    LIFE_STAGE_CATEGORIES.keys
  end

  # Helper method to get life stages by category
  def self.life_stages_by_category
    {
      infants: [:infant_0_6_months, :infant_7_12_months],
      children: [:toddler_12_23_months, :child_1_3_years, :child_4_8_years],
      adolescents: [:female_9_13_years, :male_9_13_years, :female_14_18_years, :male_14_18_years],
      adults: [:female_19_30_years, :male_19_30_years, :female_31_50_years, :male_31_50_years],
      older_adults: [:female_51_70_years, :male_51_70_years, :female_71_plus_years, :male_71_plus_years],
      pregnancy: [:pregnant_female_19_30_1st_trimester, :pregnant_female_19_30_2nd_trimester, :pregnant_female_19_30_3rd_trimester],
      lactation: [:lactating_female_19_30_0_6_months, :lactating_female_19_30_7_12_months]
    }
  end
end
