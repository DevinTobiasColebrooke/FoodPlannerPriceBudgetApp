class OnboardingProfile
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Basic Profile
  attribute :age, :integer
  attribute :sex, :string
  attribute :height, :decimal
  attribute :weight, :decimal
  attribute :activity_level, :string
  attribute :pregnancy_status, :string
  attribute :lactation_status, :string

  # Goals
  attribute :main_goal, :string
  attribute :side_goals, :string_array

  # Household
  attribute :household_size_category, :string
  attribute :number_of_people, :integer

  # Allergies
  attribute :allergies, :string_array
  attribute :allergy_severities, :hash
  attribute :allergy_notes, :hash

  # Equipment
  attribute :equipment, :string_array

  # Time & Prep Preferences
  attribute :preferred_prep_time_max_minutes, :integer
  attribute :preferred_cook_time_max_minutes, :integer
  attribute :meal_difficulty_preference, :string

  # Shopping Preferences
  attribute :shopping_difficulty_preference, :string
  attribute :weekly_budget_amount, :decimal
  attribute :budget_is_flexible, :boolean
  attribute :location_preference_type, :string
  attribute :shopping_region, :string
  attribute :latitude, :decimal
  attribute :longitude, :decimal

  # Avatar
  attribute :avatar_url, :string
  attribute :selected_avatar_identifier, :string

  # Disclosure
  attribute :acknowledged, :boolean

  validates :age, presence: true, numericality: { greater_than: 0, less_than: 120 }
  validates :sex, presence: true
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :activity_level, presence: true
  validates :main_goal, presence: true
  validates :household_size_category, presence: true
  validates :number_of_people, presence: true, numericality: { greater_than: 0 }
  validates :preferred_prep_time_max_minutes, presence: true, numericality: { greater_than: 0 }
  validates :preferred_cook_time_max_minutes, presence: true, numericality: { greater_than: 0 }
  validates :meal_difficulty_preference, presence: true
  validates :shopping_difficulty_preference, presence: true
  validates :weekly_budget_amount, presence: true, numericality: { greater_than: 0 }
  validates :location_preference_type, presence: true
  validates :acknowledged, acceptance: { accept: true, message: "must be accepted to continue" }
end
