class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :ingredient, optional: true
  belongs_to :preferred_store, class_name: 'Store', optional: true

  scope :checked, -> { where(is_checked: true) }

  def available_at_store?(store)
    # This is a placeholder - in a real app, you'd check against inventory or API
    return true if store.nil?
    store.store_type != 'online' || ingredient&.available_online?
  end
end
