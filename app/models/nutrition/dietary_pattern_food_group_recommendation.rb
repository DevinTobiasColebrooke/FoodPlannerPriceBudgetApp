class DietaryPatternFoodGroupRecommendation < ApplicationRecord
  belongs_to :dietary_pattern_calorie_level
  belongs_to :food_group

  validates :amount_value, presence: true
  validates :amount_frequency, presence: true, length: { maximum: 10 }
  validates :dietary_pattern_calorie_level_id, uniqueness: { scope: :food_group_id }
end
