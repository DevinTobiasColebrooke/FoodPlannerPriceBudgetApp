module Nutrition
  class LifeStageGroup < ApplicationRecord
    has_many :dri_values, dependent: :destroy
    has_many :nutrients, through: :dri_values
    has_many :eer_profiles, dependent: :destroy
    has_many :eer_additive_components, dependent: :destroy
    has_one :reference_anthropometry, dependent: :destroy
    has_one :growth_factor, dependent: :destroy
    has_many :pal_definitions, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    validates :min_age_months, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    # FIX: Removed `presence: true` and added `allow_nil: true` to the numericality validation.
    # This allows open-ended age ranges (e.g., 71+ years) where max_age_months is nil.
    validates :max_age_months, numericality: { only_integer: true, greater_than: :min_age_months, allow_nil: true }

    validates :sex, presence: true

    # FIX: Updated scope to correctly query for open-ended age ranges by checking for IS NULL.
    scope :for_age, ->(age_months) { where("min_age_months <= ? AND (max_age_months IS NULL OR max_age_months >= ?)", age_months, age_months) }

    scope :for_sex, ->(sex) { where(sex: sex) }
    scope :for_pregnancy, ->(trimester) { where(special_condition: 'pregnancy', trimester: trimester) }
    scope :for_lactation, ->(period) { where(special_condition: 'lactation', lactation_period: period) }
  end
end
