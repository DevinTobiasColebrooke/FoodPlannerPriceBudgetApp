module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class CalciumService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, Nutrition::Nutrient.find_by(name: 'Calcium'))
        end

        def calculate
          base_calculation = super
          return nil unless base_calculation

          # Calcium can use either RDA or AI, so we'll use whichever is available
          if base_calculation[:rda]
            base_calculation[:recommendation] = "Recommended Dietary Allowance (RDA)"
          elsif base_calculation[:ai]
            base_calculation[:recommendation] = "Adequate Intake (AI)"
          end

          base_calculation
        end
      end
    end
  end
end
