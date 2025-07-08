module NutrientCalculator
  module CoreCalculation
    module EnergyMacronutrients
      class ProteinService < BaseMacronutrientService
        def calculate
          # LOGGING: Announce that the service is running
          Rails.logger.debug "----------- PROTEIN SERVICE -----------"
          Rails.logger.debug "User Input DTO: #{@user_input.inspect}"

          rda_g_per_kg, rda_g_total = calculate_rda_values

          result = {
            rda_g_per_kg: rda_g_per_kg,
            rda_g_total: rda_g_total,
            ai_g_total: calculate_total_ai,
            amdr: calculate_amdr
          }

          Rails.logger.debug "Protein Service Result: #{result.inspect}"
          Rails.logger.debug "---------------------------------"
          result
        end

        private

        def calculate_rda_values
          Rails.logger.debug "Calculating RDA values for protein..."

          # First try to get RDA
          dri = @dri_lookup.get_dri('PROCNT')
          Rails.logger.debug "Protein RDA DRI lookup result: #{dri.inspect}"

          if dri && dri[:value]
            return calculate_from_dri(dri, 'RDA')
          end

          # If no RDA, try EAR and convert to RDA (RDA = EAR * 1.2 for protein)
          ear_dri = @dri_lookup.get_dri('PROCNT', dri_type: 'EAR')
          Rails.logger.debug "Protein EAR DRI lookup result: #{ear_dri.inspect}"

          if ear_dri && ear_dri[:value]
            # Convert EAR to RDA: RDA = EAR * 1.2 (for protein)
            converted_dri = {
              value: ear_dri[:value] * 1.2,
              unit: ear_dri[:unit],
              notes: "RDA calculated from EAR * 1.2"
            }
            return calculate_from_dri(converted_dri, 'RDA (from EAR)')
          end

          Rails.logger.debug "No RDA or EAR found for protein"
          return [nil, nil]
        end

        def calculate_from_dri(dri, source_type)
          value = dri[:value]
          unit = dri[:unit]
          rda_per_kg = nil
          rda_total = nil

          Rails.logger.debug "Processing #{source_type} with value: #{value}, unit: #{unit}"

          if unit == 'g/kg' || unit == 'g/kg body weight'
            # The DRI is provided as grams per kilogram.
            rda_per_kg = value
            rda_total = (@user_input.weight_kg * rda_per_kg).round if @user_input.weight_kg
            Rails.logger.debug "#{source_type} is per kg. Per kg: #{rda_per_kg}, Total: #{rda_total}"
          elsif unit == 'g'
            # The DRI is provided as a total gram amount.
            # This is common for children and some other life stages.
            rda_total = value.round
            # The per-kg value can be derived for this user, for informational purposes.
            rda_per_kg = (@user_input.weight_kg > 0) ? (rda_total / @user_input.weight_kg).round(2) : nil
            Rails.logger.debug "#{source_type} is total g. Total: #{rda_total}, Per kg (derived): #{rda_per_kg}"
          else
            Rails.logger.warn "Unknown unit for protein #{source_type}: #{unit}"
            return [nil, nil]
          end

          [rda_per_kg, rda_total]
        end

        def calculate_total_ai
          Rails.logger.debug "Calculating total AI for protein..."
          dri = @dri_lookup.get_dri('PROCNT', dri_type: 'AI')
          Rails.logger.debug "Protein AI DRI lookup result: #{dri.inspect}"
          return nil unless dri && dri[:value]

          value = dri[:value]
          unit = dri[:unit]
          ai_total = nil

          if unit == 'g/kg' || unit == 'g/kg body weight'
            ai_total = (@user_input.weight_kg * value).round if @user_input.weight_kg
          elsif unit == 'g'
            ai_total = value.round
          end

          Rails.logger.debug "Total AI calculated: #{ai_total}"
          ai_total
        end

        def calculate_amdr
          Rails.logger.debug "Calculating AMDR for protein..."
          amdr_percentages = @dri_lookup.get_amdr_percentage('PROCNT')
          Rails.logger.debug "Protein AMDR Percentages: #{amdr_percentages.inspect}"
          return nil unless amdr_percentages

          amdr_grams_result = calculate_amdr_grams(amdr_percentages, 4) # 4 kcal per gram of protein
          Rails.logger.debug "Protein AMDR Grams Result: #{amdr_grams_result.inspect}"

          result = {
            percent_min: amdr_percentages[:min_percent],
            percent_max: amdr_percentages[:max_percent],
            grams: amdr_grams_result
          }
          Rails.logger.debug "AMDR calculated: #{result}"
          result
        end
      end
    end
  end
end
