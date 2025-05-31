class ReferenceAnthropometry < ApplicationRecord
  belongs_to :life_stage_group

  validates :life_stage_group_id, uniqueness: true
  validates :reference_height_cm, numericality: { greater_than: 0 }, allow_nil: true
  validates :reference_weight_kg, numericality: { greater_than: 0 }, allow_nil: true
  validates :median_bmi, numericality: { greater_than: 0 }, allow_nil: true
end
