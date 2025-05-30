class Onboarding::ShoppingController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    update_onboarding_profile(shopping_params)

    if @onboarding_profile.valid?
      redirect_to new_onboarding_avatar_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def shopping_params
    params.require(:onboarding_profile).permit(
      :shopping_difficulty_preference,
      :weekly_budget_amount,
      :budget_is_flexible,
      :location_preference_type,
      :shopping_region,
      :latitude,
      :longitude
    )
  end
end
