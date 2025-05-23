class DietaryPatternCalorieLevel < ApplicationRecord
  belongs_to :dietary_pattern
  has_many :dietary_pattern_food_group_recommendations, dependent: :destroy

  validates :calorie_level, presence: true
  validates :dietary_pattern_id, uniqueness: { scope: :calorie_level }
end
