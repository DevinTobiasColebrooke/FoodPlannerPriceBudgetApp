class Nutrient < ApplicationRecord
  has_many :recipe_nutrition_items, dependent: :destroy
  has_many :recipes, through: :recipe_nutrition_items
  has_many :dri_values, dependent: :destroy

  scope :macronutrients, -> { where(category: 'macronutrient') }
  scope :micronutrients, -> { where(category: 'micronutrient') }
  scope :vitamins, -> { where(category: 'vitamin') }
  scope :minerals, -> { where(category: 'mineral') }
end
