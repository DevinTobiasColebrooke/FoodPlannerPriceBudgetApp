module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class FiberService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          age = @user_input.age_years
          sex = @user_input.sex
          weight_kg = @user_input.weight_kg

          # Calculate fiber based on age and sex
          fiber_grams = calculate_fiber_requirement(age, sex, weight_kg)

          {
            grams: fiber_grams,
            recommendation: "Adequate Intake (AI) for dietary fiber"
          }
        end

        private

        def calculate_fiber_requirement(age, sex, weight_kg)
          case age
          when 0..0.5
            nil # No AI established
          when 0.5..1
            19.0
          when 1..3
            19.0
          when 4..8
            25.0
          when 9..13
            sex == :male ? 31.0 : 26.0
          when 14..18
            sex == :male ? 38.0 : 26.0
          when 19..50
            sex == :male ? 38.0 : 25.0
          else
            sex == :male ? 30.0 : 21.0
          end
        end
      end
    end
  end
end
