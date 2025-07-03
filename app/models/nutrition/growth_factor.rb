module Nutrition
  class GrowthFactor < ApplicationRecord
    belongs_to :life_stage_group

    validates :life_stage_group_id, uniqueness: true
  end
end
