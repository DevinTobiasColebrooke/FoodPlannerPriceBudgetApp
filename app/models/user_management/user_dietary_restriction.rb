class UserDietaryRestriction < ApplicationRecord
  belongs_to :user
  belongs_to :dietary_restriction
  validates :user_id, uniqueness: { scope: :dietary_restriction_id }
end
