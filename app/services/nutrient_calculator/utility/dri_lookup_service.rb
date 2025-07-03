module NutrientCalculator
  module Utility
    class DriLookupService
      def initialize(user_input_dto)
        @user_input = user_input_dto
        @life_stage_group = determine_life_stage_group
      end

      def get_dri(nutrient_dri_identifier, dri_type: 'RDA')
        nutrient = Nutrition::Nutrient.find_by(dri_identifier: nutrient_dri_identifier)
        return nil unless nutrient && @life_stage_group

        dri_value = Nutrition::DriValue.find_by(
          nutrient: nutrient,
          life_stage_group: @life_stage_group,
          dri_type: dri_type.to_s
        )
        format_dri_output(dri_value)
      end

      def get_amdr_percentage(nutrient_dri_identifier)
        # The dri_type for AMDR percentage ranges in the database is 'AMDR_perc_range'.
        # The value is stored in the value_string column (e.g., "20-35").
        dri_value = get_dri(nutrient_dri_identifier, dri_type: 'AMDR_perc_range')
        return nil unless dri_value && dri_value[:value_text]

        min_max = dri_value[:value_text].split('-').map(&:to_f)
        return nil unless min_max.length == 2

        { min_percent: min_max[0], max_percent: min_max[1] }
      end

      def get_eer_profile
        Rails.logger.debug "----------- DRI LOOKUP SERVICE (get_eer_profile) -----------"
        # Use the most specific life stage group for EER profile lookup
        specific_life_stage_group = find_specific_life_stage_group_for_eer
        Rails.logger.debug "Life Stage Group (specific for EER): #{specific_life_stage_group.inspect}"
        return nil unless specific_life_stage_group

        user_pal_string = @user_input.physical_activity_level&.to_s
        Rails.logger.debug "User PAL String: #{user_pal_string}"

        if user_pal_string
          possible_db_terms = case user_pal_string
                              when 'sedentary'
                                ['Inactive', 'Sedentary']
                              when 'low_active'
                                ['Low active']
                              when 'moderately_active'
                                ['Moderately Active', 'Moderately active']
                              when 'active'
                                ['Active']
                              when 'very_active'
                                ['Very active']
                              else
                                []
                              end

          Rails.logger.debug "Searching for EER Profile with PAL terms: #{possible_db_terms.inspect}"
          if possible_db_terms.any?
            profile = Nutrition::EerProfile.where(life_stage_group: specific_life_stage_group)
                                           .where('lower(pal_category_applicable) IN (?)', possible_db_terms.map(&:downcase))
                                           .first
            Rails.logger.debug "Found profile with PAL: #{profile.inspect}"
            return profile if profile
          end
        end

        Rails.logger.debug "No PAL-specific profile found. Falling back to 'Average' or NULL PAL."
        fallback_profile = Nutrition::EerProfile.find_by(life_stage_group: specific_life_stage_group, pal_category_applicable: [nil, 'Average'])
        Rails.logger.debug "Fallback Profile found: #{fallback_profile.inspect}"
        Rails.logger.debug "--------------------------------------------------------"
        fallback_profile
      end

      def get_additive_component(type)
        # Use the most specific life stage group for additive component lookup
        specific_life_stage_group = find_specific_life_stage_group_for_eer
        return nil unless specific_life_stage_group

        Nutrition::EerAdditiveComponent.find_by(
          life_stage_group: specific_life_stage_group,
          component_type: type
        )
      end

      private

      def determine_life_stage_group
        age_months = @user_input.age_in_months
        sex = @user_input.sex

        query = Nutrition::LifeStageGroup.for_age(age_months).for_sex(sex)

        if @user_input.is_pregnant && @user_input.pregnancy_trimester
          query = query.where(special_condition: 'pregnancy', trimester: @user_input.pregnancy_trimester)
        elsif @user_input.is_lactating && @user_input.lactation_period
          period_string = @user_input.lactation_period.to_s.gsub(/_/, '-')
          query = query.where(special_condition: 'lactation', lactation_period: period_string)
        else
          # Ensure we don't pick up a special condition group by mistake
          query = query.where(special_condition: nil)
        end

        query.first
      end

      # Find the most specific (granular) life stage group for EER profile lookup
      def find_specific_life_stage_group_for_eer
        age_months = @user_input.age_in_months
        sex = @user_input.sex
        # Find all groups that match age and sex
        groups = Nutrition::LifeStageGroup.where('min_age_months <= ? AND (max_age_months IS NULL OR max_age_months >= ?)', age_months, age_months)
                                          .where(sex: sex)
                                          .where(special_condition: nil)
        # Pick the group with the smallest age range (most specific)
        groups.min_by do |g|
          min = g.min_age_months || 0
          max = g.max_age_months || 2000
          max - min
        end
      end

      def format_dri_output(dri_value_record)
        return nil unless dri_value_record
        {
          value: dri_value_record.value_numeric,
          value_text: dri_value_record.value_string,
          unit: dri_value_record.unit,
          notes: dri_value_record.notes
        }
      end
    end
  end
end
