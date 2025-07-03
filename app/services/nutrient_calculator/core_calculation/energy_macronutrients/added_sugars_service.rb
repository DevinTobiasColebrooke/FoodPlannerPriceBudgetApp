module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class AddedSugarsService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          eer = @energy_service.calculate[:eer_kcal_day]
          max_grams = calculate_limit_grams(10, 4) # 10% of EER, 4 kcal/g for carbohydrates

          {
            max_grams: max_grams,
            max_percent: 10,
            recommendation: "Limit added sugars to less than 10% of total daily calories"
          }
        end
      end
    end
  end
end
