class Store < ApplicationRecord
  has_many :shopping_list_items, foreign_key: 'preferred_store_id'

  validates :name, presence: true
  validates :address, length: { maximum: 255 }
  validates :zip_code, length: { maximum: 20 }
  validates :store_type, length: { maximum: 50 }
  validates :logo_url, length: { maximum: 255 }
  validates :opening_hours, length: { maximum: 255 }
  validates :delivery_info, length: { maximum: 255 }
end
