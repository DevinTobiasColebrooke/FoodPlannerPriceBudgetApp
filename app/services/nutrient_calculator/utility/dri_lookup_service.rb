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
          dri_type: dri_type.to_s.upcase
        )
        format_dri_output(dri_value)
      end

      def get_amdr_percentage(nutrient_dri_identifier)
        dri_value = get_dri(nutrient_dri_identifier, dri_type: 'AMDR')
        return nil unless dri_value && dri_value[:value_text]

        min_max = dri_value[:value_text].split('-').map(&:to_f)
        return nil unless min_max.length == 2

        { min_percent: min_max[0], max_percent: min_max[1] }
      end

      def get_eer_profile
        return nil unless @life_stage_group
        Nutrition::EerProfile.find_by(life_stage_group: @life_stage_group)
      end

      def get_additive_component(type)
        return nil unless @life_stage_group

        # This is a simplified lookup. A real implementation might need more filters.
        Nutrition::EerAdditiveComponent.find_by(
          life_stage_group: @life_stage_group,
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
