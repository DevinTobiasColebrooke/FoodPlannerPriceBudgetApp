module UserManagement
  class Allergy < ApplicationRecord
    has_many :user_allergies, dependent: :destroy
    has_many :users, through: :user_allergies

    validates :name, presence: true, uniqueness: true, length: { maximum: 100 }

    COMMON_ALLERGY_NAMES = [
      'Dairy',
      'Eggs',
      'Tree Nuts',
      'Peanuts',
      'Shellfish',
      'Soy',
      'Gluten',
      'Fish',
      'Sesame'
    ].freeze

    def self.common
      where(name: COMMON_ALLERGY_NAMES)
    end
  end
end
