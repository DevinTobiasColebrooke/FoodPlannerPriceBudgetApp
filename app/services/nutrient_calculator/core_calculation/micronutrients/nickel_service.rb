module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class NickelService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          super(user_input_dto, dri_lookup, 'NICKEL')
        end

        def calculate
          base_calculation = super
          base_calculation.merge(
            notes: generate_notes
          )
        end

        private

        def generate_notes
          base_notes = super
          additional_notes = "UL applies to supplemental forms only"

          if base_notes.empty?
            additional_notes
          else
            "#{base_notes}, #{additional_notes}"
          end
        end
      end
    end
  end
end
