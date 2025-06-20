module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class SaturatedFatService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          eer = @energy_service.calculate[:eer_kcal_day]
          max_grams = calculate_limit_grams(10, 9) # 10% of EER, 9 kcal/g for fat

          {
            max_grams: max_grams,
            max_percent: 10,
            recommendation: "Limit saturated fat to less than 10% of total daily calories"
          }
        end
      end
    end
  end
end
