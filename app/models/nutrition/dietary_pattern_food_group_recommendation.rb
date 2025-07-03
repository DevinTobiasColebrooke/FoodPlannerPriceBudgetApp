module Nutrition
  class DietaryPatternFoodGroupRecommendation < ApplicationRecord
    belongs_to :dietary_pattern_calorie_level, class_name: 'Nutrition::DietaryPatternCalorieLevel'
    belongs_to :food_group, class_name: 'Nutrition::FoodGroup'

    validates :amount_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :food_group_id, uniqueness: { scope: :dietary_pattern_calorie_level_id }
  end
end
