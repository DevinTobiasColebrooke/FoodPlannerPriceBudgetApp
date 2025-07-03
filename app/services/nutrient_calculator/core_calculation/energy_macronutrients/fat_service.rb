module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class FatService < BaseMacronutrientService
        def initialize(user_input_dto, dri_lookup, energy_service = nil, nutrient_dri_identifier = 'FAT')
          super(user_input_dto, dri_lookup, energy_service, nutrient_dri_identifier)
        end

        def calculate
          # LOGGING: Announce that the service is running
          Rails.logger.debug "----------- FAT SERVICE -----------"

          result = calculate_total_fat

          Rails.logger.debug "Fat Service Result: #{result.inspect}"
          Rails.logger.debug "---------------------------------"
          result
        end

        private

        def calculate_total_fat
          {
            ai_g_infants: calculate_ai_for_infants,
            amdr: calculate_amdr
          }
        end

        def calculate_ai_for_infants
          # Only calculate AI for infants (age < 12 months)
          return nil unless @user_input.age_in_months && @user_input.age_in_months < 12

          dri = @dri_lookup.get_dri('FAT', dri_type: 'AI')
          dri ? dri[:value] : nil
        end

        def calculate_amdr
          amdr_percentages = @dri_lookup.get_amdr_percentage('FAT')
          Rails.logger.debug "Fat AMDR Percentages: #{amdr_percentages.inspect}"
          return nil unless amdr_percentages

          amdr_grams_result = calculate_amdr_grams(amdr_percentages, 9)
          Rails.logger.debug "Fat AMDR Grams Result: #{amdr_grams_result.inspect}"

          {
            percent_min: amdr_percentages[:min_percent],
            percent_max: amdr_percentages[:max_percent],
            grams: amdr_grams_result
          }
        end
      end
    end
  end
end
