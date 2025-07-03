module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      # This is the recommended fix. It aligns the class with all other micronutrient services.
      class NiacinService < BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup)
          # Tell the base service to work with the 'NIA' nutrient.
          super(user_input_dto, dri_lookup, 'NIA')
        end

        # We override the calculate method to add our nutrient-specific notes.
        def calculate
          # 'super' calls the standard calculate method from BaseMicronutrientService
          # which returns the standardized hash {rda:, ai:, ul:, etc.}
          base_calculation = super
          return nil unless base_calculation

          # Now, we add our specific notes to the standardized result.
          base_calculation.merge(
            notes: generate_custom_notes(base_calculation[:notes])
          )
        end

        private

        def generate_custom_notes(base_notes)
          # Add the crucial context about Niacin Equivalents (NE).
          note = "Requirements are in Niacin Equivalents (NE), where 1 mg NE = 1 mg of niacin or 60 mg of dietary tryptophan."

          # For infants, the AI is for preformed niacin only.
          if @user_input.age_in_months < 7
            note += " The AI for infants 0-6 months is for preformed niacin only."
          end

          # Combine our custom note with any that might come from the base service.
          [base_notes, note].compact.reject(&:empty?).join('; ')
        end
      end
    end
  end
end
