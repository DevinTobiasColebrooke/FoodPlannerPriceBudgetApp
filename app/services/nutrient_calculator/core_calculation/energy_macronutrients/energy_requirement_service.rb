module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class EnergyRequirementService
        def initialize(user_input_dto)
          @user_input = user_input_dto
          @pal_service = NutrientCalculator::InputProcessing::PhysicalActivityCoefficientService.new(user_input_dto)
          @dri_lookup = NutrientCalculator::Utility::DriLookupService.new(user_input_dto)
        end

        def calculate
          # LOGGING: Check inputs and profile lookup
          Rails.logger.debug "########### ENERGY REQUIREMENT SERVICE ###########"
          Rails.logger.debug "User Input DTO: #{@user_input.inspect}"

          # Fetch the profile once and use it for all subsequent calculations
          profile = @dri_lookup.get_eer_profile
          Rails.logger.debug "EER Profile found: #{profile.inspect}"
          return nil unless profile

          base_eer = calculate_base_eer(profile)
          Rails.logger.debug "Calculated Base EER: #{base_eer.inspect}"
          return nil unless base_eer

          components = {
            tee: base_eer,
            growth_adjustment: calculate_growth_adjustment,
            pregnancy_adjustment: calculate_pregnancy_adjustment,
            lactation_adjustment: calculate_lactation_adjustment
          }

          eer = components.values.compact.sum
          sepv = profile.standard_error_of_predicted_value_kcal

          result = {
            nutrient: "Energy",
            eer_kcal_day: eer.round,
            sepv_kcal: sepv,
            components: components,
            prediction_interval_kcal_day: calculate_prediction_interval(eer, sepv),
            notes: generate_notes(components)
          }

          Rails.logger.debug "Final Energy Result: #{result.inspect}"
          Rails.logger.debug "##############################################"
          result
        end

        private

        def calculate_base_eer(profile)
          # Handle the two main types of EER profiles found in the data
          if profile.equation_basis == 'EER_direct'
            # For DGA reference tables, the intercept is the final EER value.
            return profile.coefficient_intercept
          end

          # For IOM formula-based profiles, apply the full equation.
          # Start with the base intercept of the equation
          eer = profile.coefficient_intercept || 0

          # Add components based on which coefficients are present in the profile.
          eer += (profile.coefficient_age_years || 0) * @user_input.age_years if profile.coefficient_age_years.present?
          eer += (profile.coefficient_age_months || 0) * @user_input.age_in_months if profile.coefficient_age_months.present?
          eer += (profile.coefficient_height_cm || 0) * @user_input.height_cm if profile.coefficient_height_cm.present?
          eer += (profile.coefficient_weight_kg || 0) * @user_input.weight_kg if profile.coefficient_weight_kg.present?

          if profile.coefficient_pal_value.present?
            pal_coefficient = @pal_service.calculate
            return nil unless pal_coefficient
            eer += profile.coefficient_pal_value * pal_coefficient
          end

          if profile.coefficient_gestation_weeks.present? && @user_input.is_pregnant?
            gestational_weeks = @user_input.gestational_weeks || 0
            eer += profile.coefficient_gestation_weeks * gestational_weeks
          end

          eer
        end

        def calculate_growth_adjustment
          return nil unless @user_input.age_in_months < 228 # < 19 years
          @dri_lookup.get_additive_component('growth')&.value_kcal_day
        end

        def calculate_pregnancy_adjustment
          return nil unless @user_input.is_pregnant?
          @dri_lookup.get_additive_component('pregnancy')&.value_kcal_day || 0
        end

        def calculate_lactation_adjustment
          return nil unless @user_input.is_lactating?
          @dri_lookup.get_additive_component('lactation')&.value_kcal_day || 0
        end

        def calculate_prediction_interval(eer, sepv)
          return nil unless eer && sepv
          lower = (eer - (1.96 * sepv)).round
          upper = (eer + (1.96 * sepv)).round
          "#{lower}-#{upper} kcal"
        end

        def generate_notes(components)
          notes = []
          notes << "Growth adjustment applied" if components[:growth_adjustment].to_i > 0
          notes << "Pregnancy adjustment applied" if components[:pregnancy_adjustment].to_i > 0
          notes << "Lactation adjustment applied" if components[:lactation_adjustment].to_i > 0
          notes.join(", ")
        end
      end
    end
  end
end
