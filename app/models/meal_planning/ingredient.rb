module MealPlanning
  class Ingredient < ApplicationRecord
    has_many :recipe_ingredients, class_name: 'MealPlanning::RecipeIngredient', dependent: :destroy
    has_many :recipes, through: :recipe_ingredients, class_name: 'MealPlanning::Recipe'
    has_many :shopping_list_items, class_name: 'Shopping::ShoppingListItem'

    validates :name, presence: true, uniqueness: true
    validates :default_unit, length: { maximum: 50 }
    validates :category, length: { maximum: 100 }
    validates :fdc_id, length: { maximum: 50 }
  end
end
