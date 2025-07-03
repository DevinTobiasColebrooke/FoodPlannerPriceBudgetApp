module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class TransFattyAcidsService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          eer = @energy_service.calculate[:eer_kcal_day]
          max_grams = calculate_limit_grams(1, 9) # 1% of EER, 9 kcal/g for fat

          {
            max_grams: max_grams,
            max_percent: 1,
            recommendation: "Limit trans fat to less than 1% of total daily calories"
          }
        end
      end
    end
  end
end
