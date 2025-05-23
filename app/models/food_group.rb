class FoodGroup < ApplicationRecord
  belongs_to :parent_food_group, class_name: 'FoodGroup', optional: true
  has_many :child_food_groups, class_name: 'FoodGroup', foreign_key: 'parent_food_group_id'
  has_many :dietary_pattern_food_group_recommendations
end
