module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class MonounsaturatedFattyAcidsService < BaseMacronutrientService
        def calculate(total_fat_result, saturated_fat_result, trans_fat_result, polyunsaturated_fat_result)
          return nil unless total_fat_result && saturated_fat_result && polyunsaturated_fat_result

          total_fat_g_min = total_fat_result.dig(:amdr, :grams, :min_grams)
          total_fat_g_max = total_fat_result.dig(:amdr, :grams, :max_grams)
          return nil unless total_fat_g_max

          sat_fat_g_limit = saturated_fat_result[:max_grams]
          trans_fat_g_limit = trans_fat_result[:max_grams] # Effectively 0
          pufa_g_ai = (polyunsaturated_fat_result.dig(:linoleic_acid, :grams) || 0) + (polyunsaturated_fat_result.dig(:ala, :grams) || 0)

          # Calculate MUFA as the residual of the AMDR range for total fat
          mufa_max = total_fat_g_max - sat_fat_g_limit - trans_fat_g_limit - pufa_g_ai
          mufa_min = total_fat_g_min - sat_fat_g_limit - trans_fat_g_limit - pufa_g_ai

          {
            mufa_calculated_range_g_min: [0, mufa_min.round].max,
            mufa_calculated_range_g_max: [0, mufa_max.round].max,
            recommendation_text: "MUFA should make up the remainder of total fat intake after accounting for essential fatty acids, saturated fat, and trans fat."
          }
        end
      end
    end
  end
end
