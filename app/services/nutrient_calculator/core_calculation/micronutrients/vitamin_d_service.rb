module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class VitaminDService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'VITD')
        end

        def calculate
          base_calculation = super
          return nil unless base_calculation

          # Add IU conversion (1 µg = 40 IU)
          if base_calculation[:rda]
            base_calculation[:rda][:iu] = (base_calculation[:rda][:value] * 40).round
          end

          base_calculation
        end
      end
    end
  end
end
