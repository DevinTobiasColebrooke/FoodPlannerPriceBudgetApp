class ShoppingListItemsController < ApplicationController
  before_action :set_shopping_list_item, only: [:update, :destroy]

  def create
    @shopping_list = current_user.shopping_lists.find_by(status: 'active')
    @shopping_list_item = @shopping_list.shopping_list_items.build(shopping_list_item_params)

    if @shopping_list_item.save
      render json: @shopping_list_item
    else
      render json: { error: @shopping_list_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @shopping_list_item.update(shopping_list_item_params)
      render json: @shopping_list_item
    else
      render json: { error: @shopping_list_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @shopping_list_item.destroy
    head :no_content
  end

  private

  def set_shopping_list_item
    @shopping_list_item = ShoppingListItem.find(params[:id])
  end

  def shopping_list_item_params
    params.require(:shopping_list_item).permit(:ingredient_id, :custom_item_name,
      :quantity_description, :quantity_numeric, :unit, :is_checked, :preferred_store_id, :notes)
  end
end
