class StoresController < ApplicationController
  layout 'mobile'

  def index
    @stores = Store.all
    @user_location = current_user&.zip_code
  end

  def show
    @store = Store.find(params[:id])
    @shopping_list = current_user.shopping_lists.find_by(status: 'active')
    @items = @shopping_list&.shopping_list_items || []
  end
end
