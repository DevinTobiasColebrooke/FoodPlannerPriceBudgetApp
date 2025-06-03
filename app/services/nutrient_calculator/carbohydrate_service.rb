module NutrientCalculator
  class CarbohydrateService < BaseMacronutrientService
    def calculate
      {
        rda_g: calculate_rda,
        ai_g: calculate_ai,
        amdr: calculate_amdr,
        added_sugars: calculate_added_sugars
      }
    end

    private

    def calculate_rda
      dri = @dri_lookup.get_dri('CHOCDF')
      return nil unless dri
      dri[:value]
    end

    def calculate_ai
      dri = @dri_lookup.get_dri('CHOCDF', dri_type: 'AI')
      return nil unless dri
      dri[:value]
    end

    def calculate_amdr
      amdr_percentages = @dri_lookup.get_amdr_percentage('CHOCDF')
      return nil unless amdr_percentages

      {
        percent_min: amdr_percentages[:min_percent],
        percent_max: amdr_percentages[:max_percent],
        grams: calculate_amdr_grams(amdr_percentages, 4) # 4 kcal per gram of carbohydrate
      }
    end

    def calculate_added_sugars
      limit_percent = @dri_lookup.get_specific_limit_percentage('ADD_SUGAR')
      return nil unless limit_percent

      {
        limit_percent_eer: limit_percent,
        limit_g: calculate_limit_grams(limit_percent, 4) # 4 kcal per gram of sugar
      }
    end
  end
end
