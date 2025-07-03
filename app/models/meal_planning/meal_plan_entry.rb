module MealPlanning
  class MealPlanEntry < ApplicationRecord
    belongs_to :user, class_name: 'UserManagement::User'
    belongs_to :recipe, class_name: 'MealPlanning::Recipe'

    validates :date, presence: true
    validates :meal_type, presence: true
    validates :user_id, uniqueness: { scope: [:date, :meal_type] }

    enum :meal_type, {
      breakfast: 'breakfast',
      lunch: 'lunch',
      dinner: 'dinner',
      snack: 'snack'
    }
  end
end
