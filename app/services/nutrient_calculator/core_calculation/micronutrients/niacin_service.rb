module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class NiacinService < BaseMicronutrientService
        def calculate
          return nil unless @dri_lookup

          age = @user_input.age_years
          sex = @user_input.sex
          pregnancy_status = @user_input.pregnancy_status
          lactation_status = @user_input.lactation_status

          # Get RDA from DRI lookup
          dri = @dri_lookup.get_niacin(age, sex, pregnancy_status, lactation_status)
          return nil unless dri

          {
            milligrams_ne: dri[:rda], # Niacin Equivalents
            recommendation: "Recommended Dietary Allowance (RDA) for niacin"
          }
        end
      end
    end
  end
end
