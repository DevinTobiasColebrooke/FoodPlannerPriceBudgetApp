module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class CarbohydrateService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          amdr_percentages = calculate_amdr_percentages
          amdr_grams = calculate_amdr_grams(amdr_percentages, 4) # 4 kcal/g for carbs

          {
            rda_g: calculate_rda,
            ai_g: calculate_ai,
            amdr_percent_min: amdr_percentages[:min_percent],
            amdr_percent_max: amdr_percentages[:max_percent],
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

        def calculate_amdr_grams(amdr_percentages, kcal_per_gram)
          return { min_g: nil, max_g: nil } unless amdr_percentages[:min_percent] && amdr_percentages[:max_percent]

          min_g = (amdr_percentages[:min_percent] * @eer / 100) / kcal_per_gram
          max_g = (amdr_percentages[:max_percent] * @eer / 100) / kcal_per_gram

          { min_g: min_g, max_g: max_g }
        end

        def calculate_added_sugars_limit_percent
          @dri_lookup.get_specific_limit_percentage('ADD_SUGAR')
        end

        def calculate_added_sugars_limit_grams
          limit_percent = calculate_added_sugars_limit_percent
          return nil unless limit_percent
          (limit_percent * @eer / 100) / 4 # 4 kcal per gram of sugar
        end
      end
    end
  end
end
