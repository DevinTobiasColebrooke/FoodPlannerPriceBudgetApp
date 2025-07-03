module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class PolyunsaturatedFattyAcidsService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          age = @user_input.age_years
          sex = @user_input.sex
          eer = @energy_service.calculate[:eer_kcal_day]

          # Get AMDR for total PUFA
          amdr = get_pufa_amdr(age, sex)
          return nil unless amdr

          # Calculate total PUFA range
          total_pufa = calculate_amdr_grams(amdr, 9) # 9 kcal/g for fat

          # Calculate essential fatty acids
          linoleic = calculate_linoleic_acid(age, sex)
          ala = calculate_ala(age, sex)

          {
            total_pufa: total_pufa,
            linoleic_acid: {
              grams: linoleic,
              recommendation: "Essential fatty acid requirement"
            },
            ala: {
              grams: ala,
              recommendation: "Essential fatty acid requirement"
            }
          }
        end

        private

        def get_pufa_amdr(age, sex)
          case age
          when 0..0.5
            { min_percent: 4.5, max_percent: 10.5 }
          when 0.5..1
            { min_percent: 4.5, max_percent: 10.5 }
          when 1..3
            { min_percent: 5, max_percent: 10 }
          when 4..8
            { min_percent: 5, max_percent: 10 }
          when 9..13
            { min_percent: 5, max_percent: 10 }
          when 14..18
            { min_percent: 5, max_percent: 10 }
          when 19..50
            { min_percent: 5, max_percent: 10 }
          else
            { min_percent: 5, max_percent: 10 }
          end
        end

        def calculate_linoleic_acid(age, sex)
          case age
          when 0..0.5
            4.4
          when 0.5..1
            4.6
          when 1..3
            7.0
          when 4..8
            10.0
          when 9..13
            sex == :male ? 12.0 : 10.0
          when 14..18
            sex == :male ? 16.0 : 11.0
          when 19..50
            sex == :male ? 17.0 : 12.0
          else
            sex == :male ? 14.0 : 11.0
          end
        end

        def calculate_ala(age, sex)
          case age
          when 0..0.5
            0.5
          when 0.5..1
            0.5
          when 1..3
            0.7
          when 4..8
            0.9
          when 9..13
            1.2
          when 14..18
            1.6
          when 19..50
            1.6
          else
            1.6
          end
        end
      end
    end
  end
end
