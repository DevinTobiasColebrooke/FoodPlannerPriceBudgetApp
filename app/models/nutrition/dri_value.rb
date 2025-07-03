module Nutrition
  class DriValue < ApplicationRecord
    belongs_to :nutrient
    belongs_to :life_stage_group

    validates :dri_type, presence: true
    validates :nutrient_id, uniqueness: { scope: [:life_stage_group_id, :dri_type] }

    scope :rda, -> { where(dri_type: 'RDA') }
    scope :ai, -> { where(dri_type: 'AI') }
    scope :ul, -> { where(dri_type: 'UL') }
    scope :amdr, -> { where(dri_type: 'AMDR') }
  end
end
