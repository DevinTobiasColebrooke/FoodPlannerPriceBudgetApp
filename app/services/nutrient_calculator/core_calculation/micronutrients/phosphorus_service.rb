module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class PhosphorusService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'P')
        end

        def calculate
          # The base service will find the RDA and UL values correctly.
          super
        end
      end
    end
  end
end
