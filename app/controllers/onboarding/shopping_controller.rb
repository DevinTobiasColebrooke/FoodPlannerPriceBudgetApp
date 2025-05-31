class Onboarding::ShoppingController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    if update_onboarding_profile(shopping_params)
      redirect_to next_step
    else
      @profile = onboarding_profile
      render :new, status: :unprocessable_entity
    end
  end

  def back
    redirect_to previous_step
  end

  private

  def shopping_params
    params.require(:onboarding_profile).permit(
      :shopping_difficulty_preference,
      :weekly_budget_amount,
      :budget_is_flexible,
      :location_preference_type,
      :zip_code
    )
  end
end
