class UserGoal < ApplicationRecord
  belongs_to :user
  belongs_to :goal
  validates :user_id, uniqueness: { scope: :goal_id }
  scope :primary, -> { where(is_primary: true) }
  scope :secondary, -> { where(is_primary: false) }
end
