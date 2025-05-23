class Goal < ApplicationRecord
  has_many :user_goals, dependent: :destroy
  has_many :users, through: :user_goals

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
