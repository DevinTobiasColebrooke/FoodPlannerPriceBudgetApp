class ShoppingListsController < ApplicationController
  layout 'mobile'
  before_action :set_shopping_list, only: [:show, :edit, :update, :destroy]
  allow_unauthenticated_access

  def index
    if Current.session&.user
      @shopping_list = Current.session.user.shopping_lists.find_or_create_by(status: 'active')
    else
      @shopping_list = ShoppingList.find_or_create_by(status: 'active', user: nil)
    end
    @stores = Store.all
    @user_location = Current.session&.user&.zip_code
  end

  def show
    @stores = Store.all
    @user_location = Current.session&.user&.zip_code
  end

  def new
    @shopping_list = ShoppingList.new
  end

  def create
    @shopping_list = Current.session&.user&.shopping_lists&.build(shopping_list_params) || ShoppingList.new(shopping_list_params)
    if @shopping_list.save
      redirect_to @shopping_list, notice: 'Shopping list was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @shopping_list.update(shopping_list_params)
      redirect_to @shopping_list, notice: 'Shopping list was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @shopping_list.destroy
    redirect_to shopping_lists_path, notice: 'Shopping list was successfully deleted.'
  end

  private

  def set_shopping_list
    @shopping_list = Current.session&.user&.shopping_lists&.find(params[:id]) || ShoppingList.find(params[:id])
  end

  def shopping_list_params
    params.require(:shopping_list).permit(:name, :status)
  end
end
