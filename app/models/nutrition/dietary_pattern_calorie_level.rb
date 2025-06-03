module Nutrition
  class DietaryPatternCalorieLevel < ApplicationRecord
    belongs_to :dietary_pattern, class_name: 'Nutrition::DietaryPattern'
    has_many :dietary_pattern_food_group_recommendations, class_name: 'Nutrition::DietaryPatternFoodGroupRecommendation', dependent: :destroy
    has_many :food_groups, through: :dietary_pattern_food_group_recommendations, class_name: 'Nutrition::FoodGroup'

    validates :calorie_level, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :dietary_pattern_id, uniqueness: { scope: :calorie_level }
  end
end
