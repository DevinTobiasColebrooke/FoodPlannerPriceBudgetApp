module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class BaseMacronutrientService
        def initialize(user_input_dto, dri_lookup, energy_service = nil, nutrient_dri_identifier = nil)
          @user_input = user_input_dto
          @dri_lookup = dri_lookup
          @energy_service = energy_service
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

        def calculate_limit_grams(percent_eer, kcal_per_gram)
          return nil unless @energy_service

          energy_result = @energy_service.calculate
          return nil unless energy_result

          eer_kcal = energy_result[:eer_kcal_day]
          return nil unless eer_kcal

          limit_kcal = (eer_kcal * percent_eer / 100.0)
          (limit_kcal / kcal_per_gram).round(1)
        end

        def calculate_amdr_grams(amdr_percentages, kcal_per_gram)
          return nil unless @energy_service && amdr_percentages

          energy_result = @energy_service.calculate
          return nil unless energy_result

          eer_kcal = energy_result[:eer_kcal_day]
          return nil unless eer_kcal

          min_percent = amdr_percentages[:min_percent]
          max_percent = amdr_percentages[:max_percent]

          min_grams = min_percent ? (eer_kcal * min_percent / 100.0 / kcal_per_gram).round(1) : nil
          max_grams = max_percent ? (eer_kcal * max_percent / 100.0 / kcal_per_gram).round(1) : nil

          {
            min_grams: min_grams,
            max_grams: max_grams
          }
        end
      end
    end
  end
end
