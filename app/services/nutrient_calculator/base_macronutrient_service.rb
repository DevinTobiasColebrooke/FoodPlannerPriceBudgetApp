module NutrientCalculator
  class BaseMacronutrientService
    def initialize(user_input_dto, dri_lookup, energy_service)
      @user_input = user_input_dto
      @dri_lookup = dri_lookup
      @energy_service = energy_service
    end

    protected

    def calculate_amdr_grams(amdr_percentages, kcal_per_gram)
      return nil unless amdr_percentages && @energy_service.calculate

      eer = @energy_service.calculate[:eer_kcal_day]
      min_percent = amdr_percentages[:min_percent]
      max_percent = amdr_percentages[:max_percent]

      {
        min_grams: ((min_percent / 100.0) * eer / kcal_per_gram).round,
        max_grams: ((max_percent / 100.0) * eer / kcal_per_gram).round
      }
    end

    def calculate_limit_grams(limit_percent, kcal_per_gram)
      return nil unless limit_percent && @energy_service.calculate

      eer = @energy_service.calculate[:eer_kcal_day]
      ((limit_percent / 100.0) * eer / kcal_per_gram).round
    end
  end
end
