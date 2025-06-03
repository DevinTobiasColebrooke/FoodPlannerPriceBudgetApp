module UserManagement
  class UserAllergy < ApplicationRecord
    belongs_to :user, class_name: 'UserManagement::User'
    belongs_to :allergy, class_name: 'UserManagement::Allergy'
    validates :user_id, uniqueness: { scope: :allergy_id }
  end
end
