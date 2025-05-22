class Nutrient < ApplicationRecord
  has_many :recipe_nutrition_items, dependent: :destroy
  has_many :recipes, through: :recipe_nutrition_items
  has_many :dri_values, dependent: :destroy

  validates :name, presence: true
  validates :dri_identifier, presence: true, uniqueness: true
  validates :nutrient_category, presence: true
  validates :default_dri_unit, presence: true
  validates :recipe_analysis_unit, presence: true

  scope :macronutrients, -> { where(nutrient_category: 'macronutrient') }
  scope :micronutrients, -> { where(nutrient_category: 'micronutrient') }
  scope :vitamins, -> { where(nutrient_category: 'vitamin') }
  scope :minerals, -> { where(nutrient_category: 'mineral') }
end
