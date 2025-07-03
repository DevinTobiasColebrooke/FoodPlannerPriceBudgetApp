module NutrientCalculator
  module CoreCalculation
    module Micronutrients
      class BaseMicronutrientService
        def initialize(user_input_dto, dri_lookup, nutrient_dri_identifier)
          @user_input = user_input_dto
          @dri_lookup = dri_lookup
          @nutrient_dri_identifier = nutrient_dri_identifier
        end

        def calculate
          # We call our new helper method `nutrient`.
          # If the nutrient doesn't exist in the DB, the helper returns nil, and this works perfectly.
          return nil unless nutrient

          {
            nutrient_name: nutrient.name,
            rda: get_rda,
            ai: get_ai,
            ul: get_ul,
            cdrr: get_cdrr,
            notes: generate_notes
          }
        end

        private

        # This is the memoization helper method.
        # The `||=` operator means "if @nutrient is nil or false, execute the right side and assign it to @nutrient".
        # It only runs the database query once.
        def nutrient
          @nutrient ||= @nutrient_dri_identifier ? Nutrition::Nutrient.find_by(dri_identifier: @nutrient_dri_identifier) : nil
        end

        def get_rda
          # Use the identifier string for the lookup service
          dri = @dri_lookup.get_dri(@nutrient_dri_identifier)
          return nil unless dri
          format_dri_value(dri)
        end

        def get_ai
          dri = @dri_lookup.get_dri(@nutrient_dri_identifier, dri_type: 'AI')
          return nil unless dri
          format_dri_value(dri)
        end

        def get_ul
          dri = @dri_lookup.get_dri(@nutrient_dri_identifier, dri_type: 'UL')
          return nil unless dri
          format_dri_value(dri)
        end

        def get_cdrr
          dri = @dri_lookup.get_dri(@nutrient_dri_identifier, dri_type: 'CDRR')
          return nil unless dri
          format_dri_value(dri)
        end

        def format_dri_value(dri)
          {
            value: dri[:value],
            unit: dri[:unit]
          }
        end

        def generate_notes
          # This method can now safely access the nutrient object!
          return "" unless nutrient

          notes = []
          notes << "Smoker adjustment applied" if @user_input.is_smoker
          notes << "UL for supplemental forms only" if nutrient.respond_to?(:ul_supplemental_only?) && nutrient.ul_supplemental_only?
          notes.join(", ")
        end
      end
    end
  end
end
