module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class CarbohydrateService < BaseMacronutrientService
        def calculate
          # Removed early return if energy_result is nil.
          # Percentage-based values should still be calculated.
          # Gram-based values will be nil if EER is nil, which is handled by `calculate_amdr_grams`.
          amdr_percentages = calculate_amdr_percentages
          amdr_grams = calculate_amdr_grams(amdr_percentages, 4) # 4 kcal/g for carbs

          {
            rda_g: calculate_rda,
            ai_g: calculate_ai,
            amdr_percent_min: amdr_percentages&.dig(:min_percent),
            amdr_percent_max: amdr_percentages&.dig(:max_percent),
            amdr_g_min: amdr_grams&.dig(:min_grams),
            amdr_g_max: amdr_grams&.dig(:max_grams)
          }
        end

        private

        def calculate_rda
          @dri_lookup.get_dri('CHOCDF')&.dig(:value)
        end

        def calculate_ai
          @dri_lookup.get_dri('CHOCDF', dri_type: 'AI')&.dig(:value)
        end

        def calculate_amdr_percentages
          @dri_lookup.get_amdr_percentage('CHOCDF') || { min_percent: nil, max_percent: nil }
        end

        # By removing the private `calculate_amdr_grams` and other unnecessary
        # private methods from this file, the class will correctly inherit and use
        # the working implementation from `BaseMacronutrientService`.
      end
    end
  end
end
