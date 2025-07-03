module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class AminoAcidsService < BaseMacronutrientService
        def calculate
          return nil unless @energy_service.calculate

          age = @user_input.age_years
          weight_kg = @user_input.weight_kg

          # Calculate requirements for each essential amino acid
          amino_acids = {
            histidine: calculate_histidine(age, weight_kg),
            isoleucine: calculate_isoleucine(age, weight_kg),
            leucine: calculate_leucine(age, weight_kg),
            lysine: calculate_lysine(age, weight_kg),
            methionine: calculate_methionine(age, weight_kg),
            phenylalanine: calculate_phenylalanine(age, weight_kg),
            threonine: calculate_threonine(age, weight_kg),
            tryptophan: calculate_tryptophan(age, weight_kg),
            valine: calculate_valine(age, weight_kg)
          }

          {
            amino_acids: amino_acids,
            recommendation: "Essential amino acid requirements based on age and weight"
          }
        end

        private

        def calculate_histidine(age, weight_kg)
          case age
          when 0..0.5
            32 * weight_kg
          when 0.5..1
            24 * weight_kg
          when 1..3
            21 * weight_kg
          when 4..8
            16 * weight_kg
          when 9..13
            12 * weight_kg
          when 14..18
            11 * weight_kg
          else
            10 * weight_kg
          end
        end

        def calculate_isoleucine(age, weight_kg)
          case age
          when 0..0.5
            88 * weight_kg
          when 0.5..1
            43 * weight_kg
          when 1..3
            28 * weight_kg
          when 4..8
            22 * weight_kg
          when 9..13
            22 * weight_kg
          when 14..18
            19 * weight_kg
          else
            20 * weight_kg
          end
        end

        def calculate_leucine(age, weight_kg)
          case age
          when 0..0.5
            196 * weight_kg
          when 0.5..1
            93 * weight_kg
          when 1..3
            63 * weight_kg
          when 4..8
            49 * weight_kg
          when 9..13
            44 * weight_kg
          when 14..18
            42 * weight_kg
          else
            39 * weight_kg
          end
        end

        def calculate_lysine(age, weight_kg)
          case age
          when 0..0.5
            180 * weight_kg
          when 0.5..1
            89 * weight_kg
          when 1..3
            58 * weight_kg
          when 4..8
            46 * weight_kg
          when 9..13
            46 * weight_kg
          when 14..18
            43 * weight_kg
          else
            30 * weight_kg
          end
        end

        def calculate_methionine(age, weight_kg)
          case age
          when 0..0.5
            85 * weight_kg
          when 0.5..1
            43 * weight_kg
          when 1..3
            27 * weight_kg
          when 4..8
            22 * weight_kg
          when 9..13
            22 * weight_kg
          when 14..18
            19 * weight_kg
          else
            15 * weight_kg
          end
        end

        def calculate_phenylalanine(age, weight_kg)
          case age
          when 0..0.5
            141 * weight_kg
          when 0.5..1
            84 * weight_kg
          when 1..3
              54 * weight_kg
          when 4..8
              33 * weight_kg
          when 9..13
              33 * weight_kg
          when 14..18
              33 * weight_kg
          else
              25 * weight_kg
          end
        end

        def calculate_threonine(age, weight_kg)
          case age
          when 0..0.5
              87 * weight_kg
          when 0.5..1
              49 * weight_kg
          when 1..3
              34 * weight_kg
          when 4..8
              28 * weight_kg
          when 9..13
              28 * weight_kg
          when 14..18
              28 * weight_kg
          else
              15 * weight_kg
          end
        end

        def calculate_tryptophan(age, weight_kg)
          case age
          when 0..0.5
              37 * weight_kg
          when 0.5..1
              17 * weight_kg
          when 1..3
              11 * weight_kg
          when 4..8
               9 * weight_kg
          when 9..13
               9 * weight_kg
          when 14..18
               9 * weight_kg
          else
               4 * weight_kg
          end
        end

        def calculate_valine(age, weight_kg)
          case age
          when 0..0.5
              161 * weight_kg
          when 0.5..1
              58 * weight_kg
          when 1..3
              37 * weight_kg
          when 4..8
              28 * weight_kg
          when 9..13
              28 * weight_kg
          when 14..18
              24 * weight_kg
          else
              26 * weight_kg
          end
        end
      end
    end
  end
end
