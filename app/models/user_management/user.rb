module UserManagement
  class User < ApplicationRecord
    attribute :guest, :boolean, default: false # Define attribute with default

    has_secure_password validations: false # Disable default has_secure_password validations
    has_many :sessions, class_name: 'UserManagement::Session', dependent: :destroy

    # Goals
    has_many :user_goals, class_name: 'UserManagement::UserGoal', dependent: :destroy
    has_many :goals, through: :user_goals, class_name: 'UserManagement::Goal'
    has_one :primary_user_goal, -> { where(is_primary: true) }, class_name: 'UserManagement::UserGoal'
    has_one :primary_goal, through: :primary_user_goal, source: :goal, class_name: 'UserManagement::Goal'

    # Allergies
    has_many :user_allergies, class_name: 'UserManagement::UserAllergy', dependent: :destroy
    has_many :allergies, through: :user_allergies, class_name: 'UserManagement::Allergy'

    # Dietary Restrictions
    has_many :user_dietary_restrictions, class_name: 'UserManagement::UserDietaryRestriction', dependent: :destroy
    has_many :dietary_restrictions, through: :user_dietary_restrictions, class_name: 'UserManagement::DietaryRestriction'

    # Kitchen Equipment
    has_many :user_kitchen_equipments, class_name: 'UserManagement::UserKitchenEquipment', dependent: :destroy
    has_many :kitchen_equipments, through: :user_kitchen_equipments, class_name: 'UserManagement::KitchenEquipment'

    # Recipes
    has_many :recipes, foreign_key: :creator_id, class_name: 'MealPlanning::Recipe'
    has_many :meal_plan_entries, class_name: 'MealPlanning::MealPlanEntry', dependent: :destroy
    has_many :planned_recipes, through: :meal_plan_entries, source: :recipe, class_name: 'MealPlanning::Recipe'

    # Shopping Lists
    has_many :shopping_lists, class_name: 'Shopping::ShoppingList', dependent: :destroy
    has_many :shopping_list_items, through: :shopping_lists, class_name: 'Shopping::ShoppingListItem'
    has_many :ingredients, through: :shopping_list_items, class_name: 'MealPlanning::Ingredient'
    has_many :preferred_stores, through: :shopping_list_items, source: :preferred_store, class_name: 'Shopping::Store'

    # Enums
    enum :cooking_time_preference, { quick: 'quick', moderate: 'moderate', leisurely: 'leisurely' }, prefix: true
    enum :meal_difficulty_preference, { easy: 'easy', medium: 'medium', involved: 'involved' }, prefix: true
    enum :shopping_difficulty_preference, { convenient: 'convenient', cheapest: 'cheapest', balanced: 'balanced' }, prefix: true
    enum :location_preference_type, { auto: 'auto', region: 'region' }, prefix: true
    enum :sex, { male: 'male', female: 'female', intersex_consideration: 'intersex_consideration' }
    enum :physical_activity_level, { sedentary: 'sedentary', low_active: 'low_active', active: 'active', very_active: 'very_active' }, prefix: true
    enum :lactation_period, { zero_to_six_months: '0-6 months', seven_to_twelve_months: '7-12 months' }, prefix: true

    # Validations only for non-guest users
    with_options unless: :guest? do |non_guest|
      non_guest.validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

      # Explicit password validations for non-guests
      non_guest.validates :password, presence: true, length: { minimum: 6 }, confirmation: true
      non_guest.validates :password_confirmation, presence: true, if: -> { password.present? } # Only if password is being set

      non_guest.validates :age_in_months, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      non_guest.validates :sex, presence: true
      non_guest.validates :height_cm, presence: true, numericality: { greater_than: 0 }
      non_guest.validates :weight_kg, presence: true, numericality: { greater_than: 0 }
      non_guest.validates :physical_activity_level, presence: true
      non_guest.validates :pregnancy_trimester, inclusion: { in: [1, 2, 3], allow_nil: true }, if: :is_pregnant?
      non_guest.validates :lactation_period, presence: true, if: :is_lactating?
    end

    # Validations that might apply to all users (guest or not) can go here
    # For example, if avatar_url had specific format validation:
    # validates :avatar_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

    # Normalizations
    normalizes :email, with: :normalize_email_conditionally

    def guest?
      !!guest # Ensures true/false
    end

    private

    def normalize_email_conditionally(email)
      return nil if guest? || email.blank?
      email.strip.downcase
    end
  end
end
