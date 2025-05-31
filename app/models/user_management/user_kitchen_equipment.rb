class UserKitchenEquipment < ApplicationRecord
  belongs_to :user
  belongs_to :kitchen_equipment
  validates :user_id, uniqueness: { scope: :kitchen_equipment_id }
end
