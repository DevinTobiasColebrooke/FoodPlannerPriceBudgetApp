module UserManagement
  class UserDietaryRestriction < ApplicationRecord
    belongs_to :user, class_name: 'UserManagement::User'
    belongs_to :dietary_restriction, class_name: 'UserManagement::DietaryRestriction'
    validates :user_id, uniqueness: { scope: :dietary_restriction_id }
  end
end
