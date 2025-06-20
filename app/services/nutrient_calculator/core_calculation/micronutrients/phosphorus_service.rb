module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class PhosphorusService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, Nutrition::Nutrient.find_by(name: 'Phosphorus'))
        end

        def calculate
          return nil unless @dri_lookup

          age = @user_input.age_years
          sex = @user_input.sex
          pregnancy_status = @user_input.pregnancy_status
          lactation_status = @user_input.lactation_status

          # Get RDA from DRI lookup
          dri = @dri_lookup.get_phosphorus(age, sex, pregnancy_status, lactation_status)
          return nil unless dri

          {
            milligrams: dri[:rda],
            recommendation: "Recommended Dietary Allowance (RDA) for phosphorus"
          }
        end
      end
    end
  end
end
