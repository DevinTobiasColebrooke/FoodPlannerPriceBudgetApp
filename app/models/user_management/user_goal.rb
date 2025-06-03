module UserManagement
  class UserGoal < ApplicationRecord
    belongs_to :user, class_name: 'UserManagement::User'
    belongs_to :goal, class_name: 'UserManagement::Goal'
    validates :user_id, uniqueness: { scope: :goal_id }
    scope :primary, -> { where(is_primary: true) }
    scope :secondary, -> { where(is_primary: false) }
  end
end
