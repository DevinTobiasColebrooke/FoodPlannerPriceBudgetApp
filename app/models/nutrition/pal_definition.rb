class PalDefinition < ApplicationRecord
  belongs_to :life_stage_group

  validates :pal_category, presence: true
  validates :pal_range_min_value, presence: true, numericality: { greater_than: 0 }
  validates :pal_range_max_value, presence: true, numericality: { greater_than: :pal_range_min_value }
  validates :life_stage_group_id, uniqueness: { scope: :pal_category }

  scope :for_category, ->(category) { where(pal_category: category) }
  scope :for_percentile, ->(percentile) { where(percentile_value: percentile) }
end
