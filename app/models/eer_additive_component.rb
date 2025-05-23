class EerAdditiveComponent < ApplicationRecord
  belongs_to :life_stage_group, optional: true

  scope :for_pregnancy, ->(trimester) { where(component_type: 'pregnancy', condition_pregnancy_trimester_filter: trimester) }
  scope :for_lactation, ->(period) { where(component_type: 'lactation', condition_lactation_period_filter: period) }
end
