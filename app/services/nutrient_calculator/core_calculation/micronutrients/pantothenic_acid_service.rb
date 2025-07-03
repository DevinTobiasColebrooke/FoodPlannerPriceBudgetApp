module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class PantothenicAcidService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'PANTAC')
        end

        def calculate
          # The base service will correctly find the AI values, as no RDA is defined.
          super
        end
      end
    end
  end
end
