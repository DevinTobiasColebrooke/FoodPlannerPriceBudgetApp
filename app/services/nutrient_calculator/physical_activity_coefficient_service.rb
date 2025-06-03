module NutrientCalculator
  class PhysicalActivityCoefficientService
    def initialize(user_input_dto)
      @user_input = user_input_dto
    end

    def calculate
      pal = PalDefinition.find_by(
        life_stage_group: find_life_stage_group,
        pal_category: @user_input.physical_activity_level
      )

      pal&.coefficient_for_eer_equation
    end

    private

    def find_life_stage_group
      LifeStageGroup.for_age(@user_input.age_in_months)
                   .for_sex(@user_input.sex)
                   .first
    end
  end
end
