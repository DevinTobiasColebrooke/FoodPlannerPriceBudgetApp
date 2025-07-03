module Nutrition
  class DietaryPattern < ApplicationRecord
    has_many :dietary_pattern_calorie_levels, class_name: 'Nutrition::DietaryPatternCalorieLevel', dependent: :destroy
    has_many :dietary_pattern_food_group_recommendations, through: :dietary_pattern_calorie_levels, class_name: 'Nutrition::DietaryPatternFoodGroupRecommendation'
    has_many :food_groups, through: :dietary_pattern_food_group_recommendations, class_name: 'Nutrition::FoodGroup'

    validates :name, presence: true, uniqueness: true
    validates :description, presence: true
  end
end
