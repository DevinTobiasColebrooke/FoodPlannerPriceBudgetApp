module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class FatService < BaseMacronutrientService
        def calculate
          {
            total_fat: calculate_total_fat
          }
        end

        private

        def calculate_total_fat
          {
            ai_g_infants: calculate_ai_for_infants,
            amdr: calculate_amdr
          }
        end

        def calculate_ai_for_infants
          dri = @dri_lookup.get_dri('FAT', dri_type: 'AI')
          dri ? dri[:value] : nil
        end

        def calculate_amdr
          amdr_percentages = @dri_lookup.get_amdr_percentage('FAT')
          return nil unless amdr_percentages

          amdr_grams_result = calculate_amdr_grams(amdr_percentages, 9)

          {
            percent_min: amdr_percentages[:min_percent],
            percent_max: amdr_percentages[:max_percent],
            grams: amdr_grams_result
          }
        end
      end
    end
  end
end
