module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class ChlorideService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'CL')
        end

        def calculate
          base_calculation = super
          return nil unless base_calculation

          # Add context based on the DRI data provided.
          base_calculation.merge(
            notes: "Chloride requirements are set on a molar equivalent basis to Sodium."
          )
        end
      end
    end
  end
end
