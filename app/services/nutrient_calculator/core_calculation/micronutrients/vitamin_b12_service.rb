module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class VitaminB12Service < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'VITB12')
        end

        def calculate
          base_calculation = super
          return nil unless base_calculation

          if @user_input.vegetarian
            base_calculation[:notes] = "Consider supplementation for vegetarian diets"
          end

          base_calculation
        end
      end
    end
  end
end
