module NutrientCalculator
  class UserInputDTO
    attr_reader :age_in_months, :sex, :height_cm, :weight_kg, :physical_activity_level,
                :pregnancy_status, :lactation_status

    def initialize(attributes = {})
      @age_in_months = attributes[:age_in_months] || (attributes[:age] * 12).to_i
      @sex = attributes[:sex]
      @height_cm = attributes[:height_cm] || attributes[:height]
      @weight_kg = attributes[:weight_kg] || attributes[:weight]
      @physical_activity_level = attributes[:activity_level]
      @pregnancy_status = attributes[:pregnancy_status]
      @lactation_status = attributes[:lactation_status]
    end
  end
end
