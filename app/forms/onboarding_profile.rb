class OnboardingProfile
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Basic Profile
  attribute :age, :integer, default: nil
  attribute :sex, :string, default: nil
  attribute :height, :decimal, default: nil
  attribute :weight, :decimal, default: nil
  attribute :activity_level, :string, default: nil
  attribute :pregnancy_status, :string, default: nil
  attribute :lactation_status, :string, default: nil
  attribute :lactation_period, :string, default: nil

  # Goals
  attribute :main_goal, :string, default: nil
  attribute :side_goals, :string_array, default: []

  # Household
  attribute :household_size_category, :string, default: nil
  attribute :number_of_people, :integer, default: nil
  attribute :household_size, :string, default: nil

  # Allergies
  attribute :allergies, :string_array, default: []
  attribute :allergies_input, :string
  attribute :allergy_severities, :hash, default: {}
  attribute :allergy_notes, :hash, default: {}

  # Equipment
  attribute :equipment, :string_array, default: []

  # Time & Prep Preferences
  attribute :preferred_prep_time_max_minutes, :integer, default: nil
  attribute :preferred_cook_time_max_minutes, :integer, default: nil
  attribute :meal_difficulty_preference, :string, default: nil

  # Shopping Preferences
  attribute :shopping_difficulty_preference, :string, default: nil
  attribute :weekly_budget_amount, :decimal, default: nil
  attribute :budget_is_flexible, :boolean, default: true
  attribute :location_preference_type, :string, default: nil
  attribute :zip_code, :string, default: nil

  # Avatar
  attribute :avatar_url, :string, default: nil
  attribute :selected_avatar_identifier, :string, default: nil

  # Disclosure
  attribute :acknowledged, :boolean, default: false

  validates :age, presence: true, numericality: { greater_than: 0, less_than: 120 }
  validates :sex, presence: true
  validates :height, presence: true, numericality: { greater_than: 0 }
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :activity_level, presence: true
  validates :main_goal, presence: true
  validates :household_size, presence: true
  validates :household_size_category, presence: true
  validates :number_of_people, presence: true, numericality: { greater_than: 0 }
  validates :preferred_prep_time_max_minutes, presence: true, numericality: { greater_than: 0 }
  validates :preferred_cook_time_max_minutes, presence: true, numericality: { greater_than: 0 }
  validates :meal_difficulty_preference, presence: true
  validates :shopping_difficulty_preference, presence: true
  validates :weekly_budget_amount, presence: true, numericality: { greater_than: 0 }
  validates :location_preference_type, presence: true
  validates :zip_code, presence: true, if: -> { location_preference_type == 'region' || location_preference_type == 'auto' }
  validates :acknowledged, acceptance: { accept: true, message: "must be accepted to continue" }
  validates :lactation_period, presence: true, if: -> { lactation_status == "true" }

  validate :main_goal_must_be_valid
  validate :side_goals_must_be_valid

  def side_goals
    Array(super)
  end

  def allergies
    Array(super)
  end

  def equipment
    Array(super)
  end

  private

  def valid_goal_names
    # Consider caching this if Goal names don't change frequently.
    @valid_goal_names ||= Goal.pluck(:name)
  rescue ActiveRecord::StatementInvalid, NameError
    Rails.logger.warn("Could not retrieve Goal names for validation. Skipping goal name validation.")
    nil # Indicates validation should be skipped or treated as a pass
  end

  def main_goal_must_be_valid
    return if main_goal.blank? # Presence validation is handled separately
    known_goal_names = valid_goal_names
    return if known_goal_names.nil? # Skip if goal names couldn't be loaded

    unless known_goal_names.include?(main_goal)
      errors.add(:main_goal, "is not a valid goal option")
    end
  end

  def side_goals_must_be_valid
    return if side_goals.empty?
    known_goal_names = valid_goal_names
    return if known_goal_names.nil? # Skip if goal names couldn't be loaded

    invalid_goals = side_goals.reject { |goal| known_goal_names.include?(goal) }
    if invalid_goals.any?
      errors.add(:side_goals, "contains invalid options: #{invalid_goals.join(', ')}")
    end
  end
end
