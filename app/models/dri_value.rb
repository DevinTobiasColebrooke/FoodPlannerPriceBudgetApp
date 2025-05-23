class DriValue < ApplicationRecord
  belongs_to :nutrient
  belongs_to :life_stage_group

  scope :rda, -> { where(dri_type: 'RDA') }
  scope :ai, -> { where(dri_type: 'AI') }
  scope :ul, -> { where(dri_type: 'UL') }
  scope :amdr, -> { where(dri_type: 'AMDR') }
end
