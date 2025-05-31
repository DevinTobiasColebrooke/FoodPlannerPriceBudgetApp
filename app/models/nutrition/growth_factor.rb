class GrowthFactor < ApplicationRecord
  belongs_to :life_stage_group

  validates :life_stage_group_id, uniqueness: true
  validates :factor_value, presence: true, numericality: { greater_than: 0 }
end
