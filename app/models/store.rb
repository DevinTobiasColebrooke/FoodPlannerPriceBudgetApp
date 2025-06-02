class Store < ApplicationRecord
  has_many :shopping_list_items, foreign_key: :preferred_store_id

  def estimated_total_cost(shopping_list)
    shopping_list.shopping_list_items.where(preferred_store_id: id).sum do |item|
      # This is a placeholder - in a real app, you'd have a price table or API integration
      item.quantity_numeric.to_f * 2.99 # Example price per unit
    end
  end

  def availability_for_shopping_list(shopping_list)
    items = shopping_list.shopping_list_items
    total_items = items.count
    available_items = items.count { |item| item.available_at_store?(self) }

    {
      progress_text: "#{available_items} of #{total_items} items available",
      progress_percentage: (available_items.to_f / total_items * 100).round,
      estimated_cost: estimated_total_cost(shopping_list)
    }
  end
end
