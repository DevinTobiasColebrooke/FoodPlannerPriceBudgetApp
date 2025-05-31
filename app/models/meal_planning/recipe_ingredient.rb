class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  validates :recipe_id, uniqueness: { scope: [:ingredient_id, :notes] }
end
