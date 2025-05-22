class UserAllergy < ApplicationRecord
  belongs_to :user
  belongs_to :allergy
  validates :user_id, uniqueness: { scope: :allergy_id }
end
