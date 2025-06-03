module UserManagement
  class UserKitchenEquipment < ApplicationRecord
    belongs_to :user, class_name: 'UserManagement::User'
    belongs_to :kitchen_equipment, class_name: 'UserManagement::KitchenEquipment'
    validates :user_id, uniqueness: { scope: :kitchen_equipment_id }
  end
end
