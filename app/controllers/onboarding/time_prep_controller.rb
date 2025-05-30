class Onboarding::TimePrepController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    update_onboarding_profile(time_prep_params)

    if @onboarding_profile.valid?
      redirect_to new_onboarding_shopping_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def time_prep_params
    params.require(:onboarding_profile).permit(
      :preferred_prep_time_max_minutes,
      :preferred_cook_time_max_minutes,
      :meal_difficulty_preference
    )
  end
end
