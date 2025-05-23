class Allergy < ApplicationRecord
  has_many :user_allergies, dependent: :destroy
  has_many :users, through: :user_allergies

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
