module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class WaterService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          age = @user_input.age_years
          sex = @user_input.sex
          weight_kg = @user_input.weight_kg
          activity_level = @user_input.physical_activity_level
          climate = @user_input.respond_to?(:climate) ? (@user_input.climate || :temperate) : :temperate
          pregnancy_status = @user_input.pregnancy_status
          lactation_status = @user_input.lactation_status

          # Calculate base water requirement
          base_water = calculate_base_water(age, sex, weight_kg, pregnancy_status, lactation_status)
          return nil unless base_water

          # Apply activity level adjustment
          activity_adjustment = calculate_activity_adjustment(activity_level)

          # Apply climate adjustment
          climate_adjustment = calculate_climate_adjustment(climate)

          total_water = (base_water * activity_adjustment * climate_adjustment).round

          {
            milliliters: total_water,
            liters: (total_water / 1000.0).round(1),
            recommendation: "Total water intake from all sources",
            ul: calculate_ul_for_toxicity(age, sex),
            cdrr: calculate_cdrr(age, sex)
          }
        end

        private

        def calculate_base_water(age, sex, weight_kg, pregnancy_status, lactation_status)
          case age
          when 0..0.5
            0.7 * weight_kg * 1000 # Convert to ml
          when 0.5..1
            0.8 * weight_kg * 1000
          when 1..3
            1.3 * weight_kg * 1000
          when 4..8
            1.7 * weight_kg * 1000
          when 9..13
            sex == :male ? 2.4 * weight_kg * 1000 : 2.1 * weight_kg * 1000
          when 14..18
            if pregnancy_status
              2.8 * weight_kg * 1000
            elsif lactation_status
              3.8 * weight_kg * 1000
            else
              sex == :male ? 3.3 * weight_kg * 1000 : 2.3 * weight_kg * 1000
            end
          else
            if pregnancy_status
              3.0 * weight_kg * 1000
            elsif lactation_status
              3.8 * weight_kg * 1000
            else
              sex == :male ? 3.7 * weight_kg * 1000 : 2.7 * weight_kg * 1000
            end
          end
        end

        def calculate_activity_adjustment(activity_level)
          case activity_level
          when :sedentary
            1.0
          when :low_active
            1.1
          when :active
            1.2
          when :very_active
            1.3
          else
            1.0
          end
        end

        def calculate_climate_adjustment(climate)
          case climate
          when :hot
            1.2
          when :humid
            1.1
          when :temperate
            1.0
          when :cold
            0.9
          else
            1.0
          end
        end

        def calculate_ul_for_toxicity(age, sex)
          {
            ul: "Not established",
            reason: "Insufficient evidence of toxicity risk in apparently healthy population."
          }
        end

        def calculate_cdrr(age, sex)
          {
            cdrr: "Not established",
            reason: "Insufficient evidence to establish a CDRR."
          }
        end
      end
    end
  end
end
