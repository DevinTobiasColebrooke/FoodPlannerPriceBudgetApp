module NutrientCalculator
  module InputProcessing
    class PhysicalActivityCoefficientService
      def initialize(user_input_dto)
        @user_input = user_input_dto
        @life_stage_group = find_life_stage_group
      end

      def calculate
        return nil unless @life_stage_group && @user_input.physical_activity_level

        pal = Nutrition::PalDefinition.find_by(
          life_stage_group: @life_stage_group,
          pal_category: @user_input.physical_activity_level.to_s
        )

        pal&.coefficient_for_eer_equation
      end

      private

      def find_life_stage_group
        age_months = @user_input.age_in_months
        sex = @user_input.sex

        query = Nutrition::LifeStageGroup.for_age(age_months).for_sex(sex)

        if @user_input.is_pregnant && @user_input.pregnancy_trimester
          query = query.where(special_condition: 'pregnancy', trimester: @user_input.pregnancy_trimester)
        elsif @user_input.is_lactating && @user_input.lactation_period
          period_string = @user_input.lactation_period.to_s.gsub(/_/, '-')
          query = query.where(special_condition: 'lactation', lactation_period: period_string)
        else
          query = query.where(special_condition: nil)
        end

        query.first
      end
    end
  end
end
