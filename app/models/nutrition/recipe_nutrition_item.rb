module Nutrition
  class RecipeNutritionItem < ApplicationRecord
    belongs_to :recipe, class_name: 'MealPlanning::Recipe'
    belongs_to :nutrient, class_name: 'Nutrition::Nutrient'

    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :unit, presence: true
    validates :nutrient, uniqueness: { scope: :recipe }
  end
end
