module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class BiotinService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'BIOT')
        end

        def calculate
          base_calculation = super
          return nil unless base_calculation

          base_calculation
        end
      end
    end
  end
end
