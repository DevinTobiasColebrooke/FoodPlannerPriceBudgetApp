module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class EnergyRequirementService
        def initialize(user_input_dto)
          @user_input = user_input_dto
          @pal_service = PhysicalActivityCoefficientService.new(user_input_dto)
          @dri_lookup = DriLookupService.new(user_input_dto)
          @bmi_service = BmiCalculationService.new(user_input_dto)
          @weight_status_service = WeightStatusCategorizationService.new(user_input_dto)
        end

        def calculate
          base_eer = calculate_base_eer
          return nil unless base_eer

          components = {
            tee: base_eer,
            growth_adjustment: calculate_growth_adjustment,
            pregnancy_adjustment: calculate_pregnancy_adjustment,
            lactation_adjustment: calculate_lactation_adjustment
          }

          eer = components.values.compact.sum

          {
            nutrient: "Energy",
            eer_kcal: eer.round,
            sepv_kcal: calculate_sepv(eer),
            components: components,
            prediction_interval_kcal_day: calculate_prediction_interval(eer),
            notes: generate_notes(components)
          }
        end

        private

        def calculate_base_eer
          profile = @dri_lookup.get_eer_formula_coefficients
          return nil unless profile

          pal = @pal_service.calculate
          return nil unless pal

          profile.coefficient_intercept +
            (profile.coefficient_age_years * (@user_input.age_in_months / 12.0)) +
            (profile.coefficient_height_cm * @user_input.height_cm) +
            (profile.coefficient_weight_kg * @user_input.weight_kg) +
            (profile.coefficient_pal_value * pal)
        end

        def calculate_growth_adjustment
          return nil unless is_child_or_adolescent?

          # Get Energy Cost of Growth (ECG) from Tables 5-11 & 5-12
          growth_data = @dri_lookup.get_energy_cost_of_growth(
            age_in_months: @user_input.age_in_months,
            sex: @user_input.sex
          )
          return nil unless growth_data

          growth_data.value_kcal_day
        end

        def calculate_pregnancy_adjustment
          return nil unless @user_input.is_pregnant?
          return 0 if @user_input.pregnancy_trimester == 1 # First trimester uses non-pregnant TEE

          pre_pregnancy_bmi = @bmi_service.calculate_pre_pregnancy_bmi
          weight_status = @weight_status_service.get_category(pre_pregnancy_bmi)

          case weight_status
          when 'underweight'
            300 # +300 kcal/d
          when 'normal_weight'
            200 # +200 kcal/d
          when 'overweight'
            150 # +150 kcal/d
          when 'obese'
            -50 # -50 kcal/d (mobilization)
          else
            0
          end
        end

        def calculate_lactation_adjustment
          return nil unless @user_input.is_lactating?

          if @user_input.lactation_period <= 6 && @user_input.is_exclusive_breastfeeding
            400 # TEE + 400 kcal/d for 0-6 months exclusive
          elsif @user_input.lactation_period <= 12
            380 # TEE + 380 kcal/d for 7-12 months partial
          else
            0
          end
        end

        def calculate_sepv(eer)
          profile = @dri_lookup.get_eer_formula_coefficients
          return nil unless profile&.standard_error_of_prediction

          profile.standard_error_of_prediction
        end

        def calculate_prediction_interval(eer)
          sepv = calculate_sepv(eer)
          return nil unless sepv

          lower = (eer - (1.96 * sepv)).round
          upper = (eer + (1.96 * sepv)).round

          "#{lower}-#{upper} kcal"
        end

        def generate_notes(components)
          notes = []
          notes << "Growth adjustment applied" if components[:growth_adjustment]
          notes << "Pregnancy adjustment applied" if components[:pregnancy_adjustment]
          notes << "Lactation adjustment applied" if components[:lactation_adjustment]
          notes.join(", ")
        end

        def is_child_or_adolescent?
          @user_input.age_in_months < 216 # 18 years * 12 months
        end
      end
    end
  end
end
