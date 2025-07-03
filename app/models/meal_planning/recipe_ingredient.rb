module MealPlanning
  class RecipeIngredient < ApplicationRecord
    belongs_to :recipe, class_name: 'MealPlanning::Recipe'
    belongs_to :ingredient, class_name: 'MealPlanning::Ingredient'

    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :unit, presence: true
    validates :recipe_id, uniqueness: { scope: [:ingredient_id, :notes] }
  end
end
