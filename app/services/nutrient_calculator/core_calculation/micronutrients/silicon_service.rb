module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class SiliconService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, Nutrition::Nutrient.find_by(name: 'Silicon'))
        end

        def calculate
          base_calculation = super
          base_calculation.merge(
            notes: generate_notes
          )
        end

        private

        def generate_notes
          notes = super
          notes << "No UL established"
          notes.join(", ")
        end
      end
    end
  end
end
