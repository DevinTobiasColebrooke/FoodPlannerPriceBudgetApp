class LifeStageGroup < ApplicationRecord
  has_many :dri_values, dependent: :destroy
  has_many :nutrients, through: :dri_values
  has_many :eer_profiles, dependent: :destroy
  has_many :eer_additive_components, dependent: :destroy
  has_one :reference_anthropometry, dependent: :destroy
  has_one :growth_factor, dependent: :destroy
  has_many :pal_definitions, dependent: :destroy

  scope :for_age, ->(age_months) { where('min_age_months <= ? AND max_age_months >= ?', age_months, age_months) }
  scope :for_sex, ->(sex) { where(sex: sex) }
  scope :for_pregnancy, ->(trimester) { where(special_condition: 'pregnancy', trimester: trimester) }
  scope :for_lactation, ->(period) { where(special_condition: 'lactation', lactation_period: period) }
end
