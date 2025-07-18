module MealPlanning
  class RecipeNutritionItem < ApplicationRecord
    belongs_to :recipe, class_name: 'MealPlanning::Recipe'
    belongs_to :nutrient, class_name: 'Nutrition::Nutrient'

    validates :value_per_recipe, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :value_per_serving, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :unit, presence: true
    validates :recipe_id, uniqueness: { scope: :nutrient_id }
  end
end
