module NutrientCalculator
  class FatService < BaseMacronutrientService
    def calculate
      {
        total_fat: calculate_total_fat,
        saturated_fat: calculate_saturated_fat,
        trans_fat: calculate_trans_fat,
        polyunsaturated_fat: calculate_polyunsaturated_fat,
        monounsaturated_fat: calculate_monounsaturated_fat
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
      return nil unless dri
      dri[:value]
    end

    def calculate_amdr
      amdr_percentages = @dri_lookup.get_amdr_percentage('FAT')
      return nil unless amdr_percentages

      {
        percent_min: amdr_percentages[:min_percent],
        percent_max: amdr_percentages[:max_percent],
        grams: calculate_amdr_grams(amdr_percentages, 9) # 9 kcal per gram of fat
      }
    end

    def calculate_saturated_fat
      limit_percent = @dri_lookup.get_specific_limit_percentage('SFA')
      return nil unless limit_percent

      {
        limit_percent_eer: limit_percent,
        limit_g: calculate_limit_grams(limit_percent, 9) # 9 kcal per gram of fat
      }
    end

    def calculate_trans_fat
      {
        recommendation_text: "As low as possible",
        limit_g: 0 # Effectively 0 for calculation purposes
      }
    end

    def calculate_polyunsaturated_fat
      {
        linoleic_ai_g: @dri_lookup.get_efa_grams('LINOLEIC'),
        ala_ai_g: @dri_lookup.get_efa_grams('ALA')
      }
    end

    def calculate_monounsaturated_fat
      total_fat = calculate_amdr
      saturated_fat = calculate_saturated_fat
      trans_fat = calculate_trans_fat
      polyunsaturated_fat = calculate_polyunsaturated_fat

      return nil unless total_fat && saturated_fat && polyunsaturated_fat

      {
        calculated_g_min: calculate_mufa_min(total_fat, saturated_fat, trans_fat, polyunsaturated_fat),
        calculated_g_max: calculate_mufa_max(total_fat, saturated_fat, trans_fat, polyunsaturated_fat),
        notes: "Calculated as residual"
      }
    end

    def calculate_mufa_min(total_fat, saturated_fat, trans_fat, polyunsaturated_fat)
      total_fat[:grams][:min_grams] -
        saturated_fat[:limit_g] -
        trans_fat[:limit_g] -
        (polyunsaturated_fat[:linoleic_ai_g] || 0) -
        (polyunsaturated_fat[:ala_ai_g] || 0)
    end

    def calculate_mufa_max(total_fat, saturated_fat, trans_fat, polyunsaturated_fat)
      total_fat[:grams][:max_grams] -
        saturated_fat[:limit_g] -
        trans_fat[:limit_g] -
        (polyunsaturated_fat[:linoleic_ai_g] || 0) -
        (polyunsaturated_fat[:ala_ai_g] || 0)
    end
  end
end
