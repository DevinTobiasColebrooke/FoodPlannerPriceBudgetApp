module Nutrition
  class PalDefinition < ApplicationRecord
    belongs_to :life_stage_group

    validates :pal_category, presence: true

    scope :for_category, ->(category) { where(pal_category: category) }
    scope :for_percentile, ->(percentile) { where(percentile_value: percentile) }
  end
end
