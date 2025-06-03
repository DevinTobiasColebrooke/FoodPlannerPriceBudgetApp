module NutrientCalculator
  class DriLookupService
    def initialize(user_input_dto)
      @user_input = user_input_dto
      @life_stage_group = determine_life_stage_group
    end

    def get_dri(nutrient_dri_identifier, dri_type: 'RDA')
      nutrient = Nutrient.find_by(dri_identifier: nutrient_dri_identifier)
      return nil unless nutrient && @life_stage_group

      dri_value = DriValue.find_by(
        nutrient: nutrient,
        life_stage_group: @life_stage_group,
        dri_type: dri_type.to_s.upcase
      )
      format_dri_output(dri_value)
    end

    def get_amdr_percentage(nutrient_dri_identifier)
      get_dri(nutrient_dri_identifier, dri_type: 'AMDR')
    end

    def get_eer_formula_coefficients
      EerProfile.find_by(life_stage_group: @life_stage_group)
    end

    def get_specific_limit_percentage(limit_name)
      DriValue.find_by(
        nutrient: Nutrient.find_by(dri_identifier: limit_name),
        life_stage_group: @life_stage_group,
        dri_type: 'LIMIT'
      )&.value_numeric
    end

    def get_efa_grams(efa_name)
      get_dri(efa_name, dri_type: 'AI')
    end

    def get_water_ai_liters
      get_dri('WATER', dri_type: 'AI')
    end

    private

    def determine_life_stage_group
      age_months = @user_input.age_in_months
      sex = @user_input.sex
      LifeStageGroup.where("min_age_months <= ? AND max_age_months >= ?", age_months, age_months)
                    .where(sex: sex)
                    .first
    end

    def format_dri_output(dri_value_record)
      return nil unless dri_value_record
      { value: dri_value_record.value_numeric, unit: dri_value_record.unit }
    end
  end
end
