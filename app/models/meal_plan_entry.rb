class MealPlanEntry < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :date, presence: true
  validates :meal_type, presence: true
  validates :user_id, uniqueness: { scope: [:date, :meal_type] }

  enum meal_type: {
    breakfast: 'breakfast',
    lunch: 'lunch',
    dinner: 'dinner',
    snack: 'snack'
  }
end
