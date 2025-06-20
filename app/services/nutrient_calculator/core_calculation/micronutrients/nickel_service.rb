module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class NickelService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, Nutrition::Nutrient.find_by(name: 'Nickel'))
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
          notes << "UL applies to supplemental forms only"
          notes.join(", ")
        end
      end
    end
  end
end
