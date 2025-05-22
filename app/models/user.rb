class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Goals
  has_many :user_goals, dependent: :destroy
  has_many :goals, through: :user_goals
  has_one :primary_user_goal, -> { where(is_primary: true) }, class_name: 'UserGoal'
  has_one :primary_goal, through: :primary_user_goal, source: :goal

  # Allergies
  has_many :user_allergies, dependent: :destroy
  has_many :allergies, through: :user_allergies

  # Dietary Restrictions
  has_many :user_dietary_restrictions, dependent: :destroy
  has_many :dietary_restrictions, through: :user_dietary_restrictions

  # Kitchen Equipment
  has_many :user_kitchen_equipments, dependent: :destroy
  has_many :kitchen_equipments, through: :user_kitchen_equipments

  # Recipes
  has_many :recipes, foreign_key: :creator_id
  has_many :meal_plan_entries, dependent: :destroy
  has_many :planned_recipes, through: :meal_plan_entries, source: :recipe

  # Shopping Lists
  has_many :shopping_lists, dependent: :destroy

  # Enums
  enum cooking_time_preference: { quick: 'quick', moderate: 'moderate', leisurely: 'leisurely' }, _prefix: true
  enum meal_difficulty_preference: { easy: 'easy', medium: 'medium', involved: 'involved' }, _prefix: true
  enum shopping_difficulty_preference: { convenient: 'convenient', cheapest: 'cheapest', balanced: 'balanced' }, _prefix: true
  enum location_preference_type: { auto: 'auto', region: 'region' }, _prefix: true
  enum sex: { male: 'male', female: 'female', intersex_consideration: 'intersex_consideration' }
  enum physical_activity_level: { sedentary: 'sedentary', low_active: 'low_active', active: 'active', very_active: 'very_active' }, _prefix: true
  enum lactation_period: { zero_to_six_months: '0-6 months', seven_to_twelve_months: '7-12 months' }, _prefix: true

  # Validations
  validates :age_in_months, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sex, presence: true
  validates :height_cm, presence: true, numericality: { greater_than: 0 }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :physical_activity_level, presence: true
  validates :pregnancy_trimester, inclusion: { in: [1, 2, 3], allow_nil: true }, if: :is_pregnant?
  validates :lactation_period, presence: true, if: :is_lactating?

  # Normalizations
  normalizes :email, with: ->(email) { email.strip.downcase }
end
