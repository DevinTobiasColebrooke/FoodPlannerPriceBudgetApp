class ShoppingList < ApplicationRecord
  belongs_to :user, class_name: 'UserManagement::User', optional: true
  has_many :shopping_list_items, dependent: :destroy

  def estimated_total_cost
    shopping_list_items.sum do |item|
      # This is a placeholder - in a real app, you'd have a price table or API integration
      item.quantity_numeric.to_f * 2.99 # Example price per unit
    end
  end
end
