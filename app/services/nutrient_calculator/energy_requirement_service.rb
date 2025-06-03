module NutrientCalculator
  class EnergyRequirementService
    def initialize(user_input_dto)
      @user_input = user_input_dto
      @pal_service = PhysicalActivityCoefficientService.new(user_input_dto)
      @dri_lookup = DriLookupService.new(user_input_dto)
    end

    def calculate
      base_eer = calculate_base_eer
      return nil unless base_eer

      eer = base_eer
      eer += pregnancy_component if @user_input.is_pregnant?
      eer += lactation_component if @user_input.is_lactating?

      {
        eer_kcal_day: eer.round,
        prediction_interval_kcal_day: calculate_prediction_interval(eer),
        notes: generate_notes
      }
    end

    private

    def calculate_base_eer
      profile = @dri_lookup.get_eer_formula_coefficients
      return nil unless profile

      pal = @pal_service.calculate
      return nil unless pal

      profile.coefficient_intercept +
        (profile.coefficient_age_years * (@user_input.age_in_months / 12.0)) +
        (profile.coefficient_height_cm * @user_input.height_cm) +
        (profile.coefficient_weight_kg * @user_input.weight_kg) +
        (profile.coefficient_pal_value * pal)
    end

    def pregnancy_component
      return 0 unless @user_input.is_pregnant?

      component = EerAdditiveComponent.for_pregnancy(@user_input.pregnancy_trimester).first
      component&.value_kcal_day || 0
    end

    def lactation_component
      return 0 unless @user_input.is_lactating?

      component = EerAdditiveComponent.for_lactation(@user_input.lactation_period).first
      component&.value_kcal_day || 0
    end

    def calculate_prediction_interval(eer)
      profile = @dri_lookup.get_eer_formula_coefficients
      return nil unless profile&.standard_error_of_prediction

      sepv = profile.standard_error_of_prediction
      lower = (eer - (1.96 * sepv)).round
      upper = (eer + (1.96 * sepv)).round

      "#{lower}-#{upper} kcal"
    end

    def generate_notes
      notes = []
      notes << "Pregnancy adjustment applied" if @user_input.is_pregnant?
      notes << "Lactation adjustment applied" if @user_input.is_lactating?
      notes.join(", ")
    end
  end
end
