module Nutrition
  class Nutrient < ApplicationRecord
    has_many :recipe_nutrition_items, dependent: :destroy
    has_many :recipes, through: :recipe_nutrition_items
    has_many :dri_values, dependent: :destroy

    validates :name, presence: true
    validates :dri_identifier, presence: true, uniqueness: true
    validates :category, presence: true
    validates :default_unit, presence: true
    validates :analysis_unit, presence: true

    scope :macronutrients, -> { where(category: 'macronutrient') }
    scope :micronutrients, -> { where(category: 'micronutrient') }
    scope :vitamins, -> { where(category: 'vitamin') }
    scope :minerals, -> { where(category: 'mineral') }
  end
end
