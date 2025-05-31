module UserManagement
  class KitchenEquipment < ApplicationRecord
    has_many :user_kitchen_equipments, dependent: :destroy
    has_many :users, through: :user_kitchen_equipments

    validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
  end
end
