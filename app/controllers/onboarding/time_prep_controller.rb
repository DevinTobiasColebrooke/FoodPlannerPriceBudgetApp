class Onboarding::TimePrepController < Onboarding::BaseController
  def new
    @profile = onboarding_profile
  end

  def create
    if update_onboarding_profile(time_prep_params)
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

  def time_prep_params
    params.require(:onboarding_profile).permit(
      :preferred_prep_time_max_minutes,
      :preferred_cook_time_max_minutes,
      :meal_difficulty_preference
    )
  end
end
