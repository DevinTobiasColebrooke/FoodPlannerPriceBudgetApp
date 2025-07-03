module Nutrition
  class FoodGroup < ApplicationRecord
    belongs_to :parent_food_group, class_name: 'FoodGroup', optional: true
    has_many :child_food_groups, class_name: 'FoodGroup', foreign_key: 'parent_food_group_id', dependent: :destroy
    has_many :dietary_pattern_food_group_recommendations, dependent: :destroy
    has_many :dietary_patterns, through: :dietary_pattern_food_group_recommendations

    validates :name, presence: true, uniqueness: true
    validates :default_unit_name, presence: true
  end
end
