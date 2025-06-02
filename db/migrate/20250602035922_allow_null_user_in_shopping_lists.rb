class AllowNullUserInShoppingLists < ActiveRecord::Migration[8.0]
  def change
    change_column_null :shopping_lists, :user_id, true
  end
end
