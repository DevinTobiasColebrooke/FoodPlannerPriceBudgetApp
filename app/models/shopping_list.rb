class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :shopping_list_items, dependent: :destroy

  enum :status, { active: 'active', completed: 'completed', archived: 'archived' }

  validates :name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, length: { maximum: 50 }
end
