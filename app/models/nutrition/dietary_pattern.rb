class DietaryPattern < ApplicationRecord
  has_many :dietary_pattern_calorie_levels, dependent: :destroy
  has_many :dietary_pattern_food_group_recommendations, through: :dietary_pattern_calorie_levels
end
