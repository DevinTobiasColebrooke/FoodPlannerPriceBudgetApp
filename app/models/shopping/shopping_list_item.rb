module Shopping
  class ShoppingListItem < ApplicationRecord
    belongs_to :shopping_list, class_name: 'Shopping::ShoppingList'
    belongs_to :ingredient, optional: true
    belongs_to :preferred_store, class_name: 'Shopping::Store', optional: true

    validates :quantity_description, length: { maximum: 100 }
    validates :unit, length: { maximum: 50 }
    validates :notes, length: { maximum: 255 }
    validates :custom_item_name, length: { maximum: 255 }
  end
end
