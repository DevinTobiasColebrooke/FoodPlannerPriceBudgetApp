module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class VitaminCService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'VITC')
        end

        def calculate
          base_calculation = super
          return nil unless base_calculation

          if @user_input.is_smoker?
            base_calculation[:rda][:value] += 35
            base_calculation[:notes] = "Smoker adjustment applied (+35 mg/day)"
          end

          base_calculation
        end
      end
    end
  end
end
