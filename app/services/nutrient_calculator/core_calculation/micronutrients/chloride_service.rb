module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class ChlorideService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, Nutrition::Nutrient.find_by(name: 'Chloride'))
        end

        def calculate
          return nil unless @dri_lookup

          age = @user_input.age_years
          sex = @user_input.sex
          pregnancy_status = @user_input.pregnancy_status
          lactation_status = @user_input.lactation_status

          # Get AI from DRI lookup
          dri = @dri_lookup.get_chloride(age, sex, pregnancy_status, lactation_status)
          return nil unless dri

          {
            milligrams: dri[:ai],
            recommendation: "Adequate Intake (AI) for chloride"
          }
        end
      end
    end
  end
end
