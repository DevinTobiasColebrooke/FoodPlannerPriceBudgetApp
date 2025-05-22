class EerProfile < ApplicationRecord
  belongs_to :life_stage_group, optional: true

  validates :name, presence: true, uniqueness: true
  validates :sex_filter, presence: true
  validates :equation_basis, presence: true

  scope :for_sex, ->(sex) { where(sex_filter: sex) }
  scope :for_age, ->(age_months) { where('age_min_months_filter <= ? AND age_max_months_filter >= ?', age_months, age_months) }
end
