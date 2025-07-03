module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class ZincService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'ZN')
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
