module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class SaturatedFatService < BaseMacronutrientService
        def calculate
          energy_result = @energy_service.calculate
          return nil unless energy_result

          limit_grams = calculate_limit_grams(10, 9) # 10% of EER, 9 kcal/g for fat

          {
            limit_grams: limit_grams,
            limit_percent_eer: 10,
            recommendation: "Limit saturated fat to less than 10% of total daily calories"
          }
        end
      end
    end
  end
end
