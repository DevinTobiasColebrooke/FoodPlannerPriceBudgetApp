module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class SodiumService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'NA')
        end

        def calculate
          # The base service correctly handles AI, UL, and the important CDRR.
          super
        end
      end
    end
  end
end
