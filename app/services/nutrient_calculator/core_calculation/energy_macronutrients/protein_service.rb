module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class ProteinService < BaseMacronutrientService
        def calculate
          {
            rda_g_per_kg: calculate_rda_per_kg,
            rda_g_total: calculate_total_rda,
            ai_g_total: calculate_total_ai,
            amdr: calculate_amdr
          }
        end

        private

        def calculate_rda_per_kg
          dri = @dri_lookup.get_dri('PROCNT')
          return nil unless dri
          dri[:value]
        end

        def calculate_total_rda
          rda_per_kg = calculate_rda_per_kg
          return nil unless rda_per_kg && @user_input.weight_kg

          (rda_per_kg * @user_input.weight_kg).round
        end

        def calculate_total_ai
          dri = @dri_lookup.get_dri('PROCNT', dri_type: 'AI')
          return nil unless dri
          dri[:value]
        end

        def calculate_amdr
          amdr_percentages = @dri_lookup.get_amdr_percentage('PROCNT')
          return nil unless amdr_percentages

          {
            percent_min: amdr_percentages[:min_percent],
            percent_max: amdr_percentages[:max_percent],
            grams: calculate_amdr_grams(amdr_percentages, 4) # 4 kcal per gram of protein
          }
        end
      end
    end
  end
end
