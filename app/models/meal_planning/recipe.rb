class Recipe < ApplicationRecord
  belongs_to :creator, class_name: 'User', optional: true

  # Ingredients
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  # Nutrition
  has_many :recipe_nutrition_items, dependent: :destroy
  has_many :nutrients, through: :recipe_nutrition_items

  # Meal Planning
  has_many :meal_plan_entries, dependent: :destroy
  has_many :planned_users, through: :meal_plan_entries, source: :user

  # Validations
  validates :name, presence: true
  validates :number_of_servings, presence: true, numericality: { greater_than: 0 }
  validates :difficulty_level, inclusion: { in: %w[easy medium hard] }, allow_nil: true

  # Scopes
  scope :public_recipes, -> { where(is_public: true) }
  scope :by_difficulty, ->(level) { where(difficulty_level: level) }
  scope :quick_recipes, -> { where('prep_time_minutes <= ?', 30) }
  scope :recent, -> { order(created_at: :desc) }
end
