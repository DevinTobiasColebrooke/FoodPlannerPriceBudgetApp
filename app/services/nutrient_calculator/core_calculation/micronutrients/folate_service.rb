module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class FolateService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'FOL')
        end

        def calculate
          base_calculation = super
          return nil unless base_calculation

          # Add DFE (Dietary Folate Equivalents) conversion
          if base_calculation[:rda]
            base_calculation[:rda][:dfe] = base_calculation[:rda][:value]
            base_calculation[:notes] = "Values in Dietary Folate Equivalents (DFE)"
          end

          base_calculation
        end
      end
    end
  end
end
