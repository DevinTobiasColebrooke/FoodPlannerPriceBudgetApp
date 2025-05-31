class DietaryRestriction < ApplicationRecord
  has_many :user_dietary_restrictions, dependent: :destroy
  has_many :users, through: :user_dietary_restrictions

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
